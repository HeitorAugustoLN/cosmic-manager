{ lib, ... }:
let
  inherit (lib)
    getAttrFromPath
    mkEnableOption
    mkIf
    mkMerge
    mkPackageOption
    optionalAttrs
    optionals
    setAttrByPath
    ;
  inherit (lib.cosmic) applyExtraConfig mkAssertions mkSettingsOption;
in
{
  mkCosmicApplication =
    {
      configurationVersion,
      description ? null,
      extraConfig ? _: { },
      extraOptions ? { },
      hasSettings ? true,
      identifier,
      imports ? [ ],
      maintainers,
      name,
      originalName ? name,
      package ? name,
      settingsDescription ? "Configuration entries for ${originalName}.",
      settingsOptions ? { },
      settingsExample ? null,
    }@args:
    let
      loc = [
        "programs"
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
            {
              enable = mkEnableOption originalName;
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

          config = mkIf cfg.enable (mkMerge [
            {
              assertions = mkAssertions name [
                {
                  assertion = cfg.enable -> config.wayland.desktopManager.cosmic.enable;
                  message = "COSMIC Desktop declarative configuration must be enabled to use ${originalName} module.";
                }
              ];

              home.packages = optionals (cfg.package != null) [ cfg.package ];
            }

            (mkIf hasSettings {
              wayland.desktopManager.cosmic = {
                configFile.${identifier} = {
                  entries = cfg.settings;
                  version = configurationVersion;
                };
              };
            })

            (mkIf (args ? extraConfig) (applyExtraConfig {
              inherit cfg extraConfig opts;
            }))
          ]);

          meta = {
            inherit maintainers;
            cosmicInfo = {
              inherit description;
              url = args.url or opts.package.default.meta.homepage;
              path = loc;
            };
          };
        };
    in
    {
      imports = imports ++ [ module ];
    };
}
