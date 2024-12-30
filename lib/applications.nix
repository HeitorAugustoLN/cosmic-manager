{ lib, ... }:
{
  mkCosmicApplication =
    {
      configurationVersion,
      extraConfig ? _cfg: { },
      extraOptions ? { },
      hasSettings ? true,
      identifier,
      imports ? [ ],
      maintainers,
      name,
      originalName ? name,
      package,
      settingsDescription ? "Configuration entries for ${originalName}.",
      settingsOptions ? { },
      settingsExample ? null,
    }@args:
    let
      module =
        { config, pkgs, ... }:
        let
          cfg = config.programs.${name};
        in
        {
          options.programs.${name} =
            {
              enable = lib.mkEnableOption originalName;
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

          config = lib.mkIf cfg.enable (
            lib.mkMerge [
              {
                assertions = [
                  {
                    assertion = cfg.enable -> config.wayland.desktopManager.cosmic.enable;
                    message = "COSMIC Desktop declarative configuration must be enabled to use ${originalName} module.";
                  }
                ];

                home.packages = lib.optionals (cfg.package != null) [ cfg.package ];
              }

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
