{ lib, ... }:
let
  inherit (builtins) attrValues filter length;
  inherit (lib)
    getAttrFromPath
    mkEnableOption
    mkIf
    mkMerge
    mkPackageOption
    optionalAttrs
    optionals
    pipe
    setAttrByPath
    ;
  inherit (lib.cosmic)
    applyExtraConfig
    mkAssertion
    mkAssertions
    mkSettingsOption
    ;
in
{
  mkCosmicApplet =
    {
      configurationVersion,
      description ? null,
      extraConfig ? _: { },
      extraOptions ? { },
      hasSettings ? true,
      identifier,
      imports ? [ ],
      isBuiltin ? true,
      maintainers,
      name,
      originalName ? name,
      package ? if isBuiltin then null else name,
      settingsDescription ? "Configuration entries for ${originalName} applet.",
      settingsOptions ? { },
      settingsExample ? null,
    }@args:
    let
      loc = [
        "wayland"
        "desktopManager"
        "cosmic"
        "applets"
        name
      ];

      module =
        {
          config,
          options,
          pkgs,
          ...
        }:
        let
          cfg = getAttrFromPath loc config;
          opts = getAttrFromPath loc options;
        in
        {
          options = setAttrByPath loc (
            optionalAttrs (!isBuiltin) {
              enable = mkEnableOption "${originalName} applet";
              package = mkPackageOption pkgs package {
                extraDescription = "Set to `null` if you don't want to install the package.";
                nullable = true;
              };
            }
            // optionalAttrs hasSettings {
              settings = mkSettingsOption {
                description = settingsDescription;
                example = settingsExample;
                options = settingsOptions;
              };
            }
            // extraOptions
          );

          config =
            let
              anySettingsSet =
                (pipe cfg.settings [
                  attrValues
                  (filter (x: x != null))
                  length
                ]) > 0;

              enabled = if isBuiltin then anySettingsSet else cfg.enable;
            in
            assert mkAssertion name (
              isBuiltin -> hasSettings
            ) "Applet module must have settings if it is a built-in applet.";
            mkIf enabled (mkMerge [
              {
                assertions = mkAssertions name [
                  {
                    assertion = enabled -> config.wayland.desktopManager.cosmic.enable;
                    message = "COSMIC Desktop declarative configuration must be enabled to use ${originalName} applet module.";
                  }
                ];
              }

              (mkIf (!isBuiltin) {
                home.packages = optionals (cfg.package != null) [ cfg.package ];
              })

              (mkIf hasSettings {
                wayland.desktopManager.cosmic = {
                  configFile.${identifier} = {
                    entries = cfg.settings;
                    version = configurationVersion;
                  };
                };
              })

              (mkIf (args ? extraConfig) (applyExtraConfig {
                inherit
                  cfg
                  enabled
                  extraConfig
                  opts
                  ;
              }))
            ]);

          meta = {
            inherit maintainers;
            cosmicInfo = {
              inherit description;
              url =
                if isBuiltin then
                  "https://github.com/pop-os/cosmic-applets"
                else
                  args.url or opts.package.default.meta.homepage;
              path = loc;
            };
          };
        };
    in
    {
      imports = imports ++ [ module ];
    };
}
