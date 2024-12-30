{ lib, ... }:
let
  inherit (lib.cosmic.options) mkNullOrOption;
in
lib.cosmic.applets.mkCosmicApplet {
  name = "app-list";
  originalName = "App Tray";
  identifier = "com.system76.CosmicAppList";
  configurationVersion = 1;

  maintainers = [ lib.maintainers.HeitorAugustoLN ];

  settingsOptions = {
    enable_drag_source = mkNullOrOption {
      type = lib.types.bool;
      example = true;
      description = ''
        Whether to enable dragging applications from the application list.
      '';
    };

    favorites = mkNullOrOption {
      type = with lib.types; listOf str;
      example = [
        "firefox"
        "com.system76.CosmicFiles"
        "com.system76.CosmicEdit"
        "com.system76.CosmicTerm"
        "com.system76.CosmicSettings"
      ];
      description = ''
        A list of applications to always be shown in the application list.
      '';
    };

    filter_top_levels = mkNullOrOption {
      type =
        with lib.types;
        ronOptionalOf (ronEnum [
          "ActiveWorkspace"
          "ConfiguredOutput"
        ]);
      example = {
        __type = "optional";
        value = {
          __type = "enum";
          variant = "ActiveWorkspace";
        };
      };
      description = ''
        The top level filter to use for the application list.
      '';
    };
  };

  settingsExample = {
    enable_drag_source = true;
    favorites = [
      "firefox"
      "com.system76.CosmicFiles"
      "com.system76.CosmicEdit"
      "com.system76.CosmicTerm"
      "com.system76.CosmicSettings"
    ];
    filter_top_levels = {
      __type = "optional";
      value = {
        __type = "enum";
        variant = "ActiveWorkspace";
      };
    };
  };
}
