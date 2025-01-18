{ config, lib, ... }:
{
  options.wayland.desktopManager.cosmic.compositor =
    let
      inherit (lib.cosmic) defaultNullOpts mkRonExpression;
    in
    lib.mkOption {
      type = lib.types.submodule {
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
        };
      };
      default = { };
      example = mkRonExpression 0 {
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
      } null;
      description = ''
        The COSMIC compositor configuration.
      '';
    };

  config.wayland.desktopManager.configFile."com.system76.CosmicComp" =
    let
      cfg = config.wayland.desktopManager.cosmic;
    in
    lib.mkIf (cfg.compositor != { }) {
      entries = cfg.compositor;
      version = 1;
    };
}
