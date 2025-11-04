{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.wayland.desktopManager.cosmic.panels =
    let
      inherit (lib.cosmic) defaultNullOpts;

      panelSubmodule = lib.types.submodule {
        freeformType = with lib.types; attrsOf anything;
        options = {
          anchor =
            defaultNullOpts.mkRonEnum [ "Bottom" "Left" "Right" "Top" ]
              {
                __type = "enum";
                variant = "Bottom";
              }
              ''
                The position of the panel on the screen.
              '';

          anchor_gap = defaultNullOpts.mkBool true ''
            Whether there should be a gap between the panel and the screen edge.
          '';

          # HACK: Submodule options won't show up if maybeRonRaw comes before it.
          autohide =
            defaultNullOpts.mkNullable
              (lib.types.ronOptionalOf (
                lib.types.submodule {
                  freeformType = with lib.types; attrsOf anything;
                  options = {
                    handle_size = lib.mkOption {
                      type =
                        with lib.types;
                        maybeRonRaw (
                          addCheck ints.u32 (x: x > 0)
                          // {
                            description = "Non-zero 32-bit unsigned integer";
                          }
                        );
                      example = 4;
                      description = ''
                        The size of the handle in pixels.
                      '';
                    };
                    transition_time = lib.mkOption {
                      type = with lib.types; maybeRonRaw ints.u32;
                      example = 200;
                      description = ''
                        The time in milliseconds it should take to transition the panel hiding.
                      '';
                    };
                    wait_time = lib.mkOption {
                      type = with lib.types; maybeRonRaw ints.u32;
                      example = 1000;
                      description = ''
                        The time in milliseconds without pointer focus before the panel hides.
                      '';
                    };
                  };
                }
              ))
              {
                __type = "optional";
                value = {
                  handle_size = 4;
                  transition_time = 200;
                  wait_time = 1000;
                };
              }
              ''
                Whether the panel should autohide and the settings for autohide.
                If set the `value` is set to `null`, the panel will not autohide.
              '';

          background =
            defaultNullOpts.mkNullableWithRaw
              (
                with lib.types;
                either (ronEnum [
                  "Dark"
                  "Light"
                  "ThemeDefault"
                ]) (ronTupleEnumOf (ronTupleOf float 3) [ "Color" ] 1)
              )
              {
                __type = "enum";
                variant = "Dark";
              }
              ''
                The appearance of the panel.
              '';

          expand_to_edges = defaultNullOpts.mkBool true ''
            Whether the panel should expand to the edges of the screen.
          '';

          name = lib.mkOption {
            type = lib.types.str;
            example = "Panel";
            description = ''
              The name of the panel.
            '';
          };

          opacity = defaultNullOpts.mkNullableWithRaw (lib.types.numbers.between 0.0 1.0) 1.0 ''
            The opacity of the panel.
          '';

          output =
            defaultNullOpts.mkNullableWithRaw
              (
                with lib.types;
                either (ronEnum [
                  "Active"
                  "All"
                ]) (ronTupleEnumOf str [ "Name" ] 1)
              )
              {
                __type = "enum";
                variant = "Name";
                value = [ "Virtual-1" ];
              }
              ''
                The output(s) the panel should be displayed on.
              '';

          plugins_center =
            defaultNullOpts.mkRonOptionalOf (with lib.types; listOf str)
              {
                __type = "optional";
                value = [ "com.system76.CosmicAppletTime" ];
              }
              ''
                The center applets of the panel.
              '';

          plugins_wings =
            defaultNullOpts.mkRonOptionalOf (with lib.types; ronTupleOf (listOf str) 2)
              {
                __type = "optional";
                value = {
                  __type = "tuple";
                  value = [
                    [
                      "com.system76.CosmicPanelWorkspacesButton"
                      "com.system76.CosmicPanelAppButton"
                      "com.system76.CosmicAppletWorkspaces"
                    ]
                    [
                      "com.system76.CosmicAppletInputSources"
                      "com.system76.CosmicAppletStatusArea"
                      "com.system76.CosmicAppletTiling"
                      "com.system76.CosmicAppletAudio"
                      "com.system76.CosmicAppletNetwork"
                      "com.system76.CosmicAppletBattery"
                      "com.system76.CosmicAppletNotifications"
                      "com.system76.CosmicAppletBluetooth"
                      "com.system76.CosmicAppletPower"
                    ]
                  ];
                };
              }
              ''
                The plugins that will be displayed on the right and left sides of the panel, respectively.
              '';

          size =
            defaultNullOpts.mkRonEnum [ "XS" "S" "M" "L" "XL" ]
              {
                __type = "enum";
                variant = "M";
              }
              ''
                The size of the panel.
              '';
        };
      };
    in
    defaultNullOpts.mkNullable (lib.types.listOf panelSubmodule)
      [
        {
          anchor = {
            __type = "enum";
            variant = "Bottom";
          };
          anchor_gap = true;
          autohide = {
            __type = "optional";
            value = {
              handle_size = 4;
              transition_time = 200;
              wait_time = 1000;
            };
          };
          background = {
            __type = "enum";
            variant = "Dark";
          };
          expand_to_edges = true;
          name = "Panel";
          opacity = 1.0;
          output = {
            __type = "enum";
            variant = "Name";
            value = [ "Virtual-1" ];
          };
          plugins_center = {
            __type = "optional";
            value = [ "com.system76.CosmicAppletTime" ];
          };
          plugins_wings = {
            __type = "optional";
            value = {
              __type = "tuple";
              value = [
                [
                  "com.system76.CosmicPanelWorkspacesButton"
                  "com.system76.CosmicPanelAppButton"
                  "com.system76.CosmicAppletWorkspaces"
                ]
                [
                  "com.system76.CosmicAppletInputSources"
                  "com.system76.CosmicAppletStatusArea"
                  "com.system76.CosmicAppletTiling"
                  "com.system76.CosmicAppletAudio"
                  "com.system76.CosmicAppletNetwork"
                  "com.system76.CosmicAppletBattery"
                  "com.system76.CosmicAppletNotifications"
                  "com.system76.CosmicAppletBluetooth"
                  "com.system76.CosmicAppletPower"
                ]
              ];
            };
          };
          size = {
            __type = "enum";
            variant = "M";
          };
        }
      ]
      ''
        The panels that will be displayed on the desktop.
      '';

  config =
    let
      cfg = config.wayland.desktopManager.cosmic;

      version = 1;
    in
    lib.mkIf (cfg.panels != null) {
      wayland.desktopManager.cosmic.configFile = lib.mkMerge (
        [
          {
            "com.system76.CosmicPanel" = {
              entries.entries = map (panel: panel.name) cfg.panels;
              inherit version;
            };
          }
        ]
        ++ (map (panel: {
          "com.system76.CosmicPanel.${panel.name}" = {
            entries = panel;
            inherit version;
          };
        }) cfg.panels)
      );

      home.activation.restartCosmicPanel = lib.mkIf (cfg.panels != null) (
        lib.hm.dag.entryAfter [
          "configureCosmic"
        ] "run ${lib.getExe pkgs.killall} .cosmic-panel-wrapped || true"
      );
    };
}
