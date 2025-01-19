{ lib, ... }:
lib.cosmic.applets.mkCosmicApplet {
  name = "app-list";
  originalName = "App Tray";
  identifier = "com.system76.CosmicAppList";
  configurationVersion = 1;

  maintainers = [ lib.maintainers.HeitorAugustoLN ];

  settingsOptions =
    let
      inherit (lib.cosmic) defaultNullOpts;
    in
    {
      enable_drag_source = defaultNullOpts.mkBool true ''
        Whether to enable dragging applications from the application list.
      '';

      favorites =
        defaultNullOpts.mkListOf lib.types.str
          [
            "firefox"
            "com.system76.CosmicFiles"
            "com.system76.CosmicEdit"
            "com.system76.CosmicTerm"
            "com.system76.CosmicSettings"
          ]
          ''
            A list of applications to always be shown in the application list.
          '';

      filter_top_levels =
        defaultNullOpts.mkRonOptionalOf
          (lib.types.ronEnum [
            "ActiveWorkspace"
            "ConfiguredOutput"
          ])
          {
            __type = "optional";
            value = {
              __type = "enum";
              variant = "ActiveWorkspace";
            };
          }
          ''
            The top level filter to use for the application list.
          '';
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
