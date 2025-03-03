{ lib, ... }:
lib.cosmic.applications.mkCosmicApplication {
  name = "cosmic-player";
  originalName = "COSMIC Media Player";
  identifier = "com.system76.CosmicPlayer";
  configurationVersion = 1;

  maintainers = [ lib.maintainers.HeitorAugustoLN ];

  settingsOptions =
    let
      inherit (lib.cosmic) defaultNullOpts;
    in
    {
      app_theme =
        defaultNullOpts.mkRonEnum [ "Dark" "Light" "System" ]
          {
            __type = "enum";
            variant = "System";
          }
          ''
            The theme of the application.
          '';
    };

  settingsExample = {
    app_theme = {
      __type = "enum";
      variant = "System";
    };
  };
}
