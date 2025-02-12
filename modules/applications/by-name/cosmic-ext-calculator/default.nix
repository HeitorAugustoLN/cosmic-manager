{ lib, ... }:
lib.cosmic.applications.mkCosmicApplication {
  name = "cosmic-ext-calculator";
  originalName = "COSMIC Calculator";
  identifier = "dev.edfloreshz.Calculator";
  configurationVersion = 1;

  maintainers = [ lib.maintainers.HeitorAugustoLN ];

  # NOTE: There is also a history configuration entry, but I will not add it here, since I don't think it belong as a setting, but rather an state entry
  # It will probably open a PR there, fixing it.
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
