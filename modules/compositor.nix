{ config, lib, ... }:
{
  options.wayland.desktopManager.cosmic.compositor =
    let
      inherit (lib.cosmic) defaultNullOpts;

      compositorSubmodule =
        let
          inherit (lib.cosmic) mkRonExpression;

          inputSubmodule = lib.types.submodule {
            freeformType = with lib.types; attrsOf cosmicEntryValue;
            options = {
              acceleration =
                let
                  accelerationSubmodule = lib.types.submodule {
                    freeformType = with lib.types; attrsOf cosmicEntryValue;
                    options = {
                      profile = lib.mkOption {
                        type =
                          with lib.types;
                          maybeRonRaw (
                            ronOptionalOf (
                              maybeRonRaw (ronEnum [
                                "Adaptive"
                                "Flat"
                              ])
                            )
                          );
                        example = mkRonExpression 0 {
                          __type = "optional";
                          value = {
                            __type = "enum";
                            variant = "Flat";
                          };
                        } null;
                      };

                      speed = lib.mkOption {
                        type = with lib.types; maybeRonRaw float;
                        example = 0.0;
                        description = ''
                          The speed of the input device.
                        '';
                      };
                    };
                  };
                in
                defaultNullOpts.mkNullable (lib.types.ronOptionalOf accelerationSubmodule)
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
                defaultNullOpts.mkRonOptionalOf (with lib.types; ronTupleOf float 6)
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
                  (lib.types.ronEnum [
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
                defaultNullOpts.mkRonOptionalOf lib.types.bool
                  {
                    __type = "optional";
                    value = true;
                  }
                  ''
                    Whether to disable the input device while typing.
                  '';

              left_handed =
                defaultNullOpts.mkRonOptionalOf lib.types.bool
                  {
                    __type = "optional";
                    value = false;
                  }
                  ''
                    Whether the input device is left-handed.
                  '';

              map_to_output =
                defaultNullOpts.mkRonOptionalOf lib.types.str
                  {
                    __type = "optional";
                    value = "HDMI-A-1";
                  }
                  ''
                    The output to map the input device to.
                  '';

              middle_button_emulation =
                defaultNullOpts.mkRonOptionalOf lib.types.bool
                  {
                    __type = "optional";
                    value = false;
                  }
                  ''
                    Whether to emulate the middle button.
                  '';

              rotation_angle =
                defaultNullOpts.mkRonOptionalOf lib.types.ints.u32
                  {
                    __type = "optional";
                    value = 0;
                  }
                  ''
                    The rotation angle of the input device.
                  '';

              scroll_config =
                let
                  scrollConfigSubmodule = lib.types.submodule {
                    freeformType = with lib.types; attrsOf cosmicEntryValue;
                    options = {
                      method = lib.mkOption {
                        type =
                          with lib.types;
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
                        example = mkRonExpression 0 {
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

                      natural_scroll = lib.mkOption {
                        type = with lib.types; maybeRonRaw (ronOptionalOf (maybeRonRaw bool));
                        example = true;
                        description = ''
                          Whether to enable natural scrolling.
                        '';
                      };

                      scroll_button = lib.mkOption {
                        type = with lib.types; maybeRonRaw (ronOptionalOf (maybeRonRaw ints.u32));
                        example = 2;
                        description = ''
                          The scroll button of the input device.
                        '';
                      };

                      scroll_factor = lib.mkOption {
                        type = with lib.types; maybeRonRaw (ronOptionalOf (maybeRonRaw float));
                        example = 1.0;
                        description = ''
                          The scroll factor of the input device.
                        '';
                      };
                    };
                  };
                in
                defaultNullOpts.mkNullable (lib.types.ronOptionalOf scrollConfigSubmodule)
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
                  tapConfigSubmodule = lib.types.submodule {
                    freeformType = with lib.types; attrsOf cosmicEntryValue;
                    options = {
                      button_map = lib.mkOption {
                        type =
                          with lib.types;
                          maybeRonRaw (
                            ronOptionalOf (
                              maybeRonRaw (ronEnum [
                                "LeftMiddleRight"
                                "LeftRightMiddle"
                              ])
                            )
                          );
                        example = mkRonExpression 0 {
                          __type = "optional";
                          value = {
                            __type = "enum";
                            variant = "LeftMiddleRight";
                          };
                        } null;
                      };

                      drag = lib.mkOption {
                        type = with lib.types; maybeRonRaw bool;
                        example = true;
                        description = ''
                          Whether to enable drag.
                        '';
                      };

                      drag_lock = lib.mkOption {
                        type = with lib.types; maybeRonRaw bool;
                        example = true;
                        description = ''
                          Whether to enable drag lock.
                        '';
                      };

                      enabled = lib.mkOption {
                        type = with lib.types; maybeRonRaw bool;
                        example = true;
                        description = ''
                          Whether to enable tap.
                        '';
                      };
                    };
                  };
                in
                defaultNullOpts.mkNullable (lib.types.ronOptionalOf tapConfigSubmodule)
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
        lib.types.submodule {
          freeformType = with lib.types; attrsOf cosmicEntryValue;
          options = {
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

            workspaces =
              let
                workspacesSubmodule = lib.types.submodule {
                  freeformType = with lib.types; attrsOf cosmicEntryValue;
                  options = {
                    workspace_layout = lib.mkOption {
                      type =
                        with lib.types;
                        maybeRonRaw (ronEnum [
                          "Horizontal"
                          "Vertical"
                        ]);
                      example = mkRonExpression 0 {
                        __type = "enum";
                        variant = "Vertical";
                      } null;
                      description = ''
                        The layout of the workspaces.

                        If set to Horizontal, workspaces are arranged horizontally.
                        If set to Vertical, workspaces are arranged vertically.
                      '';
                    };

                    workspace_mode = lib.mkOption {
                      type =
                        with lib.types;
                        maybeRonRaw (ronEnum [
                          "Global"
                          "OutputBound"
                        ]);
                      example = mkRonExpression 0 {
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
                xkbConfigSubmodule = lib.types.submodule {
                  freeformType = with lib.types; attrsOf cosmicEntryValue;
                  options = {
                    layout = lib.mkOption {
                      type = with lib.types; maybeRonRaw str;
                      example = "br";
                      description = ''
                        The keyboard layout.
                      '';
                    };

                    model = lib.mkOption {
                      type = with lib.types; maybeRonRaw str;
                      example = "pc104";
                      description = ''
                        The keyboard model.
                      '';
                    };

                    options = lib.mkOption {
                      type = with lib.types; maybeRonRaw (ronOptionalOf (maybeRonRaw str));
                      example = "terminate:ctrl_alt_bksp";
                      description = ''
                        The keyboard options.
                      '';
                    };

                    repeat_delay = lib.mkOption {
                      type = with lib.types; maybeRonRaw ints.u32;
                      example = 600;
                      description = ''
                        The keyboard repeat delay.
                      '';
                    };

                    repeat_rate = lib.mkOption {
                      type = with lib.types; maybeRonRaw ints.u32;
                      example = 25;
                      description = ''
                        The keyboard repeat rate.
                      '';
                    };

                    rules = lib.mkOption {
                      type = with lib.types; maybeRonRaw str;
                      description = ''
                        The keyboard rules.
                      '';
                    };

                    variant = lib.mkOption {
                      type = with lib.types; maybeRonRaw str;
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
    lib.mkIf (cfg.compositor != null) {
      entries = cfg.compositor;
      version = 1;
    };
}
