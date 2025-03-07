{ config, lib, ... }:
let
  inherit (lib) mkIf mkOption types;
  inherit (lib.cosmic) defaultNullOpts mkRONExpression;
in
{
  options.wayland.desktopManager.cosmic.compositor =
    let
      compositorSubmodule =
        let
          inputSubmodule = types.submodule {
            freeformType = with types; attrsOf anything;
            options = {
              acceleration =
                let
                  accelerationSubmodule = types.submodule {
                    freeformType = with types; attrsOf anything;
                    options = {
                      profile = mkOption {
                        type =
                          with types;
                          maybeRonRaw (
                            ronOptionalOf (
                              maybeRonRaw (ronEnum [
                                "Adaptive"
                                "Flat"
                              ])
                            )
                          );
                        example = mkRONExpression 0 {
                          __type = "optional";
                          value = {
                            __type = "enum";
                            variant = "Flat";
                          };
                        } null;
                      };

                      speed = mkOption {
                        type = with types; maybeRonRaw float;
                        example = 0.0;
                        description = ''
                          The speed of the input device.
                        '';
                      };
                    };
                  };
                in
                defaultNullOpts.mkNullable (types.ronOptionalOf accelerationSubmodule)
                  {
                    __type = "optional";
                    value = {
                      profile = {
                        __type = "optional";
                        value = {
                          __type = "enum";
                          variant = "Flat";
                        };
                      };
                      speed = 0.0;
                    };
                  }
                  ''
                    The acceleration configuration for the input device.
                  '';

              calibration =
                defaultNullOpts.mkRonOptionalOf (with types; ronTupleOf float 6)
                  {
                    __type = "optional";
                    value = {
                      __type = "tuple";
                      value = [
                        1.0
                        0.0
                        0.0
                        0.0
                        1.0
                        0.0
                      ];
                    };
                  }
                  ''
                    The calibration matrix for the input device.
                  '';

              click_method =
                defaultNullOpts.mkRonOptionalOf
                  (types.ronEnum [
                    "ButtonAreas"
                    "Clickfinger"
                  ])
                  {
                    __type = "optional";
                    value = {
                      __type = "enum";
                      variant = "ButtonAreas";
                    };
                  }
                  ''
                    The click method for the input device.
                  '';

              disable_while_typing =
                defaultNullOpts.mkRonOptionalOf types.bool
                  {
                    __type = "optional";
                    value = true;
                  }
                  ''
                    Whether to disable the input device while typing.
                  '';

              left_handed =
                defaultNullOpts.mkRonOptionalOf types.bool
                  {
                    __type = "optional";
                    value = false;
                  }
                  ''
                    Whether the input device is left-handed.
                  '';

              map_to_output =
                defaultNullOpts.mkRonOptionalOf types.str
                  {
                    __type = "optional";
                    value = "HDMI-A-1";
                  }
                  ''
                    The output to map the input device to.
                  '';

              middle_button_emulation =
                defaultNullOpts.mkRonOptionalOf types.bool
                  {
                    __type = "optional";
                    value = false;
                  }
                  ''
                    Whether to emulate the middle button.
                  '';

              rotation_angle =
                defaultNullOpts.mkRonOptionalOf types.ints.u32
                  {
                    __type = "optional";
                    value = 0;
                  }
                  ''
                    The rotation angle of the input device.
                  '';

              scroll_config =
                let
                  scrollConfigSubmodule = types.submodule {
                    freeformType = with types; attrsOf anything;
                    options = {
                      method = mkOption {
                        type =
                          with types;
                          maybeRonRaw (
                            ronOptionalOf (
                              maybeRonRaw (ronEnum [
                                "Edge"
                                "NoScroll"
                                "OnButtonDown"
                                "TwoFinger"
                              ])
                            )
                          );
                        example = mkRONExpression 0 {
                          __type = "optional";
                          value = {
                            __type = "enum";
                            variant = "Edge";
                          };
                        } null;
                        description = ''
                          The scroll method of the input device.
                        '';
                      };

                      natural_scroll = mkOption {
                        type = with types; maybeRonRaw (ronOptionalOf (maybeRonRaw bool));
                        example = true;
                        description = ''
                          Whether to enable natural scrolling.
                        '';
                      };

                      scroll_button = mkOption {
                        type = with types; maybeRonRaw (ronOptionalOf (maybeRonRaw ints.u32));
                        example = 2;
                        description = ''
                          The scroll button of the input device.
                        '';
                      };

                      scroll_factor = mkOption {
                        type = with types; maybeRonRaw (ronOptionalOf (maybeRonRaw float));
                        example = 1.0;
                        description = ''
                          The scroll factor of the input device.
                        '';
                      };
                    };
                  };
                in
                defaultNullOpts.mkNullable (types.ronOptionalOf scrollConfigSubmodule)
                  {
                    method = {
                      __type = "optional";
                      value = {
                        __type = "enum";
                        variant = "Edge";
                      };
                    };
                    natural_scroll = {
                      __type = "optional";
                      value = true;
                    };
                    scroll_button = {
                      __type = "optional";
                      value = 2;
                    };
                    scroll_factor = {
                      __type = "optional";
                      value = 1.0;
                    };
                  }
                  ''
                    The scroll configuration for the input device.
                  '';

              state =
                defaultNullOpts.mkRonEnum [ "Disabled" "DisabledOnExternalMouse" "Enabled" ]
                  {
                    __type = "enum";
                    variant = "Enabled";
                  }
                  ''
                    The state of the input module.

                    If set to Disabled, the input module is disabled.
                    If set to DisabledOnExternalMouse, the input module is disabled when an external mouse is connected.
                    If set to Enabled, the input module is enabled.
                  '';

              tap_config =
                let
                  tapConfigSubmodule = types.submodule {
                    freeformType = with types; attrsOf anything;
                    options = {
                      button_map = mkOption {
                        type =
                          with types;
                          maybeRonRaw (
                            ronOptionalOf (
                              maybeRonRaw (ronEnum [
                                "LeftMiddleRight"
                                "LeftRightMiddle"
                              ])
                            )
                          );
                        example = mkRONExpression 0 {
                          __type = "optional";
                          value = {
                            __type = "enum";
                            variant = "LeftMiddleRight";
                          };
                        } null;
                      };

                      drag = mkOption {
                        type = with types; maybeRonRaw bool;
                        example = true;
                        description = ''
                          Whether to enable drag.
                        '';
                      };

                      drag_lock = mkOption {
                        type = with types; maybeRonRaw bool;
                        example = true;
                        description = ''
                          Whether to enable drag lock.
                        '';
                      };

                      enabled = mkOption {
                        type = with types; maybeRonRaw bool;
                        example = true;
                        description = ''
                          Whether to enable tap.
                        '';
                      };
                    };
                  };
                in
                defaultNullOpts.mkNullable (types.ronOptionalOf tapConfigSubmodule)
                  {
                    button_map = {
                      __type = "optional";
                      value = {
                        __type = "enum";
                        variant = "LeftMiddleRight";
                      };
                    };
                    drag = {
                      __type = "optional";
                      value = true;
                    };
                    drag_lock = {
                      __type = "optional";
                      value = true;
                    };
                    enabled = {
                      __type = "optional";
                      value = true;
                    };
                  }
                  ''
                    The tap configuration for the input device.
                  '';
            };
          };
        in
        types.submodule {
          freeformType = with types; attrsOf anything;
          options = {
            accessibility_zoom =
              let
                accessibilityZoomSubmodule = types.submodule {
                  freeformType = with types; attrsOf anything;
                  options = {
                    increment = mkOption {
                      type = with types; maybeRonRaw ints.u32;
                      example = 50;
                      description = ''
                        The zoom increment.
                      '';
                    };

                    start_on_login = mkOption {
                      type = with types; maybeRonRaw bool;
                      example = false;
                      description = ''
                        Whether to start the accessibility zoom on login.
                      '';
                    };

                    view_moves = mkOption {
                      type =
                        with types;
                        maybeRonRaw (ronEnum [
                          "Centered"
                          "Continuously"
                          "OnEdge"
                        ]);
                      example = mkRONExpression 0 {
                        __type = "enum";
                        variant = "Continuously";
                      } null;
                      description = ''
                        The view moves of the accessibility zoom.
                      '';
                    };
                  };
                };
              in
              defaultNullOpts.mkNullable accessibilityZoomSubmodule
                {
                  increment = 50;
                  start_on_login = false;
                  view_moves = {
                    __type = "enum";
                    variant = "Continuously";
                  };
                }
                ''
                  The accessibility zoom configuration.
                '';

            active_hint = defaultNullOpts.mkBool true ''
              Whether to show the active window hint.
            '';

            autotile = defaultNullOpts.mkBool false ''
              Whether to automatically tile windows.
            '';

            autotile_behavior =
              defaultNullOpts.mkRonEnum [ "Global" "PerWorkspace" ]
                {
                  __type = "enum";
                  variant = "PerWorkspace";
                }
                ''
                  Automatic tiling behavior.

                  If set to Global, autotile applies to all windows in all workspaces.
                  If set to PerWorkspace, autotile only applies to new windows, and new workspaces.
                '';

            cursor_follows_focus = defaultNullOpts.mkBool false ''
              Whether the cursor should follow the focused window.
            '';

            descale_xwayland = defaultNullOpts.mkBool false ''
              Whether to let XWayland windows be scaled by themselves.
            '';

            edge_snap_threshold = defaultNullOpts.mkU32 0 ''
              The edge snap threshold.
            '';

            focus_follows_cursor = defaultNullOpts.mkBool false ''
              Whether the focused window should follow the cursor.
            '';

            focus_follows_cursor_delay = defaultNullOpts.mkUnsignedInt 250 ''
              The delay in milliseconds before the focused window follows the cursor.
            '';

            input_default =
              defaultNullOpts.mkNullable inputSubmodule
                {
                  acceleration = {
                    profile = {
                      __type = "optional";
                      value = {
                        __type = "enum";
                        variant = "Flat";
                      };
                    };
                    speed = 0.0;
                  };
                  state = {
                    __type = "enum";
                    variant = "Enabled";
                  };
                }
                ''
                  The input configuration for mice.
                '';

            input_touchpad =
              defaultNullOpts.mkNullable inputSubmodule
                {
                  acceleration = {
                    profile = {
                      __type = "optional";
                      value = {
                        __type = "enum";
                        variant = "Flat";
                      };
                    };
                    speed = 0.0;
                  };
                  click_method = {
                    __type = "optional";
                    value = {
                      __type = "enum";
                      variant = "Clickfinger";
                    };
                  };
                  disable_while_typing = {
                    __type = "optional";
                    value = true;
                  };
                  state = {
                    __type = "enum";
                    variant = "Enabled";
                  };
                  tap_config = {
                    button_map = {
                      __type = "optional";
                      value = {
                        __type = "enum";
                        variant = "LeftMiddleRight";
                      };
                    };
                    drag = {
                      __type = "optional";
                      value = true;
                    };
                    drag_lock = {
                      __type = "optional";
                      value = true;
                    };
                    enabled = {
                      __type = "optional";
                      value = true;
                    };
                  };
                }
                ''
                  The input configuration for touchpad.
                '';

            keyboard_config =
              let
                keyboardConfigSubmodule = types.submodule {
                  freeformType = with types; attrsOf anything;
                  options.numlock_state = mkOption {
                    type =
                      with types;
                      maybeRonRaw (ronEnum [
                        "BootOff"
                        "BootOn"
                        "LastBoot"
                      ]);
                    example = mkRONExpression 0 {
                      __type = "enum";
                      variant = "BootOff";
                    } null;
                    description = ''
                      The numlock state of the keyboard.
                    '';
                  };
                };
              in
              defaultNullOpts.mkNullable keyboardConfigSubmodule
                {
                  numlock_state = {
                    __type = "enum";
                    variant = "BootOff";
                  };
                }
                ''
                  The keyboard configuration.
                '';

            workspaces =
              let
                workspacesSubmodule = types.submodule {
                  freeformType = with types; attrsOf anything;
                  options = {
                    workspace_layout = mkOption {
                      type =
                        with types;
                        maybeRonRaw (ronEnum [
                          "Horizontal"
                          "Vertical"
                        ]);
                      example = mkRONExpression 0 {
                        __type = "enum";
                        variant = "Vertical";
                      } null;
                      description = ''
                        The layout of the workspaces.

                        If set to Horizontal, workspaces are arranged horizontally.
                        If set to Vertical, workspaces are arranged vertically.
                      '';
                    };

                    workspace_mode = mkOption {
                      type =
                        with types;
                        maybeRonRaw (ronEnum [
                          "Global"
                          "OutputBound"
                        ]);
                      example = mkRONExpression 0 {
                        __type = "enum";
                        variant = "OutputBound";
                      } null;
                      description = ''
                        The mode of the workspaces.

                        If set to Global, workspaces are shared across all outputs.
                        If set to OutputBound, workspaces are bound to the output they are created on.
                      '';
                    };
                  };
                };
              in
              defaultNullOpts.mkNullable workspacesSubmodule
                {
                  workspace_layout = {
                    __type = "enum";
                    variant = "Vertical";
                  };
                  workspace_mode = {
                    __type = "enum";
                    variant = "OutputBound";
                  };
                }
                ''
                  The workspaces configuration for the COSMIC compositor.
                '';

            xkb_config =
              let
                xkbConfigSubmodule = types.submodule {
                  freeformType = with types; attrsOf anything;
                  options = {
                    layout = mkOption {
                      type = with types; maybeRonRaw str;
                      example = "br";
                      description = ''
                        The keyboard layout.
                      '';
                    };

                    model = mkOption {
                      type = with types; maybeRonRaw str;
                      example = "pc104";
                      description = ''
                        The keyboard model.
                      '';
                    };

                    options = mkOption {
                      type = with types; maybeRonRaw (ronOptionalOf (maybeRonRaw str));
                      example = "terminate:ctrl_alt_bksp";
                      description = ''
                        The keyboard options.
                      '';
                    };

                    repeat_delay = mkOption {
                      type = with types; maybeRonRaw ints.u32;
                      example = 600;
                      description = ''
                        The keyboard repeat delay.
                      '';
                    };

                    repeat_rate = mkOption {
                      type = with types; maybeRonRaw ints.u32;
                      example = 25;
                      description = ''
                        The keyboard repeat rate.
                      '';
                    };

                    rules = mkOption {
                      type = with types; maybeRonRaw str;
                      description = ''
                        The keyboard rules.
                      '';
                    };

                    variant = mkOption {
                      type = with types; maybeRonRaw str;
                      example = "dvorak";
                      description = ''
                        The keyboard variant.
                      '';
                    };
                  };
                };
              in
              defaultNullOpts.mkNullable xkbConfigSubmodule
                {
                  layout = "br";
                  model = "pc104";
                  options = {
                    __type = "optional";
                    value = "terminate:ctrl_alt_bksp";
                  };
                  repeat_delay = 600;
                  repeat_rate = 25;
                  rules = "";
                  variant = "dvorak";
                }
                ''
                  The keyboard configuration for the COSMIC compositor.
                '';
          };
        };
    in
    defaultNullOpts.mkNullable compositorSubmodule
      {
        active_hint = true;
        autotile = false;

        autotile_behavior = {
          __type = "enum";
          variant = "PerWorkspace";
        };

        cursor_follows_focus = false;
        descale_xwayland = false;
        edge_snap_threshold = 0;
        focus_follows_cursor = false;
        focus_follows_cursor_delay = 250;

        workspaces = {
          workspace_layout = {
            __type = "enum";
            variant = "Vertical";
          };

          workspace_mode = {
            __type = "enum";
            variant = "OutputBound";
          };
        };

        xkb_config = {
          layout = "br";
          model = "pc104";
          options = {
            __type = "optional";
            value = "terminate:ctrl_alt_bksp";
          };
          repeat_delay = 600;
          repeat_rate = 25;
          rules = "";
          variant = "dvorak";
        };
      }
      ''
        The COSMIC compositor configuration.
      '';

  config.wayland.desktopManager.cosmic.configFile."com.system76.CosmicComp" =
    let
      cfg = config.wayland.desktopManager.cosmic;
    in
    mkIf (cfg.compositor != null) {
      entries = cfg.compositor;
      version = 1;
    };
}
