{ lib, ... }:
lib.cosmic.applications.mkCosmicApplication {
  name = "cosmic-ext-tweaks";
  originalName = "COSMIC Calculator";
  identifier = "dev.edfloreshz.CosmicTweaks";
  configurationVersion = 1;

  maintainers = [ lib.maintainers.HeitorAugustoLN ];

  settingsOptions.app_theme =
    lib.cosmic.defaultNullOpts.mkRonEnum [ "Dark" "Light" "System" ]
      {
        __type = "enum";
        variant = "System";
      }
      ''
        The theme of the application.
      '';

  settingsExample.app_theme = {
    __type = "enum";
    variant = "System";
  };
}
