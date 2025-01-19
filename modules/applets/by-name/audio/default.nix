{ lib, ... }:
lib.cosmic.applets.mkCosmicApplet {
  name = "audio";
  originalName = "Sound";
  identifier = "com.system76.CosmicAppletAudio";
  configurationVersion = 1;

  maintainers = [ lib.maintainers.HeitorAugustoLN ];

  settingsOptions =
    let
      inherit (lib.cosmic) defaultNullOpts;
    in
    {
      show_media_controls_in_top_panel = defaultNullOpts.mkBool true ''
        Whether to show media controls in the top panel.
      '';
    };

  settingsExample = {
    show_media_controls_in_top_panel = true;
  };
}
