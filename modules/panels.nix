{ config, lib, ... }:
let
  inherit (lib.cosmic.options) mkNullOrOption;

  cfg = config.wayland.desktopManager.cosmic;
in
{
  options.wayland.desktopManager.cosmic.panels =
    let
      panelSubmodule = lib.types.submodule {
        freeformType = with lib.types; attrsOf cosmicEntryValue;
        options = {
          anchor = mkNullOrOption {
            type = lib.types.ronEnum [
              "Bottom"
              "Left"
              "Right"
              "Top"
            ];
            example = {
              __type = "enum";
              variant = "Bottom";
            };
            description = ''
              The position of the panel on the screen.
            '';
          };
          anchor_gap = mkNullOrOption {
            type = lib.types.bool;
            example = true;
            description = ''
              Whether there should be a gap between the panel and the screen edge.
            '';
          };
          autohide = mkNullOrOption {
            type = lib.types.ronOptionalOf (
              lib.types.submodule {
                freeformType = with lib.types; attrsOf cosmicEntryValue;
                options = {
                  handle_size = mkNullOrOption {
                    type =
                      with lib.types;
                      (addCheck lib.types.ints.u32 (x: x > 0))
                      // {
                        description = "32 bit unsigned integer; must be greater than 0";
                      };
                    example = 4;
                    description = ''
                      The size of the handle in pixels.
                    '';
                  };
                  transition_time = lib.mkOption {
                    type = lib.types.ints.u32;
                    example = 200;
                    description = ''
                      The time in milliseconds it should take to transition the panel hiding.
                    '';
                  };
                  wait_time = lib.mkOption {
                    type = lib.types.ints.u32;
                    example = 1000;
                    description = ''
                      The time in milliseconds without pointer focus before the panel hides.
                    '';
                  };
                };
              }
            );
            example = {
              __type = "optional";
              value = {
                handle_size = 4;
                transition_time = 200;
                wait_time = 1000;
              };
            };
            description = ''
              Whether the panel should autohide and the settings for autohide.
              If set the `value` is set to `null`, the panel will not autohide.
            '';
          };
          background = mkNullOrOption {
            type =
              with lib.types;
              either (ronEnum [
                "Dark"
                "Light"
                "ThemeDefault"
              ]) (ronTupleEnumOf (listOf float) [ "Color" ]);
            example = {
              __type = "enum";
              variant = "Dark";
            };
            description = ''
              The appearance of the panel.
            '';
          };
          expand_to_edges = mkNullOrOption {
            type = lib.types.bool;
            example = true;
            description = ''
              Whether the panel should expand to the edges of the screen.
            '';
          };
          name = lib.mkOption {
            type = lib.types.str;
            example = "Panel";
            description = ''
              The name of the panel.
            '';
          };
          opacity = mkNullOrOption {
            type = lib.types.numbers.between 0 1;
            example = 1.0;
            description = ''
              The opacity of the panel.
            '';
          };
          output = mkNullOrOption {
            type =
              with lib.types;
              either (ronEnum [
                "Active"
                "All"
              ]) (ronTupleEnumOf str [ "Name" ]);
            example = {
              __type = "enum";
              variant = "Name";
              value = "Virtual-1";
            };
            description = ''
              The output(s) the panel should be displayed on.
            '';
          };
          plugins_center = mkNullOrOption {
            type = with lib.types; ronOptionalOf (listOf str);
            example = {
              __type = "optional";
              value = [ "com.system76.CosmicAppletTime" ];
            };
            description = ''
              The center plugins of the panel.
            '';
          };
          plugins_wings = mkNullOrOption {
            type = with lib.types; ronOptionalOf (ronTupleOf (listOf str));
            example = {
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
            description = ''
              The plugins that will be displayed on the right and left sides of the panel, respectively.
            '';
          };
          size = mkNullOrOption {
            type = lib.types.ronEnum [
              "XS"
              "S"
              "M"
              "L"
              "XL"
            ];
            example = {
              __type = "enum";
              variant = "M";
            };
            description = ''
              The size of the panel.
            '';
          };
        };
      };
    in
    mkNullOrOption {
      type = lib.types.listOf panelSubmodule;
      example = [
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
            value = "Virtual-1";
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
      ];
    };

  config =
    let
      version = 1;
    in
    lib.mkIf (cfg.enable && cfg.panels != null) {
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
    };
}
