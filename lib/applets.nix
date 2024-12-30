{ lib, ... }:
{
  mkCosmicApplet =
    {
      configurationVersion,
      extraConfig ? _cfg: { },
      extraOptions ? { },
      hasSettings ? true,
      identifier,
      imports ? [ ],
      isBuiltin ? true,
      maintainers,
      name,
      originalName ? name,
      package ? if isBuiltin then null else package,
      settingsDescription ? "Configuration entries for ${originalName} applet.",
      settingsOptions ? { },
      settingsExample ? null,
    }@args:
    let
      module =
        { config, pkgs, ... }:
        let
          cfg = config.wayland.desktopManager.cosmic.applets.${name};
        in
        {
          options.wayland.desktopManager.cosmic.applets.${name} =
            lib.optionalAttrs (!isBuiltin) {
              enable = lib.mkEnableOption "${originalName} applet";
              package = lib.mkPackageOption pkgs package {
                extraDescription = "Set to `null` if you don't want to install the package.";
                nullable = true;
              };
            }
            // lib.optionalAttrs hasSettings {
              settings = lib.cosmic.options.mkSettingsOption {
                description = settingsDescription;
                example = settingsExample;
                options = settingsOptions;
              };
            }
            // extraOptions;

          config =
            let
              anySettingsSet =
                (lib.pipe cfg.settings [
                  builtins.attrValues
                  (builtins.filter (x: x != null))
                  builtins.length
                ]) > 0;
              enabled = if isBuiltin then anySettingsSet else cfg.enable;
            in
            lib.mkIf enabled (
              lib.mkMerge [
                {
                  assertions = [
                    {
                      assertion = enabled -> config.wayland.desktopManager.cosmic.enable;
                      message = "COSMIC Desktop declarative configuration must be enabled to use ${originalName} applet module.";
                    }
                  ];
                }

                (lib.optionalAttrs (!isBuiltin) {
                  home.packages = lib.optionals (cfg.package != null) [ cfg.package ];
                })

                (lib.optionalAttrs hasSettings {
                  wayland.desktopManager.cosmic = {
                    configFile.${identifier} = {
                      entries = cfg.settings;
                      version = configurationVersion;
                    };
                  };
                })

                (lib.optionalAttrs (args ? extraConfig) (
                  lib.cosmic.modules.applyExtraConfig { inherit cfg extraConfig; }
                ))
              ]
            );

          meta.maintainers = maintainers;
        };
    in
    {
      imports = imports ++ [ module ];
    };
}
