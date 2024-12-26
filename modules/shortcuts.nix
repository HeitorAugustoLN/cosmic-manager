{ config, lib, ... }:
let
  cfg = config.wayland.desktopManager.cosmic;

  inherit (lib.cosmic.options) mkNullOrOption;
  inherit (lib.cosmic.utils) capitalizeWord;
in
{
  options.wayland.desktopManager.cosmic.shortcuts =
    let
      /*
        NOTE: Last updated: 27/12/2024 at 5:43 GMT-3 with the following commit:
        https://github.com/pop-os/cosmic-settings-daemon/commit/61c76a9d060827402eeb9fe92cae73ce159d66e5
        When updating, look in:
          - config/src/shortcuts/action.rs -> For valid actions
          - config/src/shortcuts/modifier.rs -> For valid modifiers
          - config/src/shortcuts/binding.rs -> For shortcuts hashmap keys such as description, modifiers, and key
          - config/src/shortcuts/mod.rs -> For the Shortcut struct, which should always be HashMap<Binding, Action>, but check for changes
      */
      shortcutSubmodule =
        let
          direction = [
            "Down"
            "Left"
            "Right"
            "Up"
          ];

          enumVariants = [
            # Close the active window
            "Close"
            # Show a debug overlay, if enabled in the compositor build
            "Debug"
            # Disable a default shortcut binding
            "Disable"
            # Change focus to the last workspace
            "LastWorkspace"
            # Maximize the active window
            "Maximize"
            # Migrate the active workspace to the next output
            "MigrateWorkspaceToNextOutput"
            # Migrate the active workspace to the previous output
            "MigrateWorkspaceToPreviousOutput"
            # Minimize the active window
            "Minimize"
            # Move a window to the last workspace
            "MoveToLastWorkspace"
            # Move a window to the next output
            "MoveToNextOutput"
            # Move a window to the next workspace
            "MoveToNextWorkspace"
            # Move a window to the previous output
            "MoveToPreviousOutput"
            # Move a window to the previous workspace
            "MoveToPreviousWorkspace"
            # Change focus to the next output
            "NextOutput"
            # Change focus to the next workspace
            "NextWorkspace"
            # Change focus to the previous output
            "PreviousOutput"
            # Change focus to the previous workspace
            "PreviousWorkspace"
            # Move a window to the last workspace
            "SendToLastWorkspace"
            # Move a window to the next output
            "SendToNextOutput"
            # Move a window to the next workspace
            "SendToNextWorkspace"
            # Move a window to the previous output
            "SendToPreviousOutput"
            # Move a window to the previous workspace
            "SendToPreviousWorkspace"
            # Swap positions of the active window with another
            "SwapWindow"
            # Stop the compositor
            "Terminate"
            # Toggle the orientation of a tiling group
            "ToggleOrientation"
            # Toggle window stacking for the active window
            "ToggleStacking"
            # Toggle the sticky state of the active window
            "ToggleSticky"
            # Toggle tiling mode of the active workspace
            "ToggleTiling"
            # Toggle between tiling and floating window states for the active window
            "ToggleWindowFloating"
          ];

          focusDirection = [
            "Down"
            "In"
            "Left"
            "Right"
            "Out"
            "Up"
          ];

          orientation = [
            "Horizontal"
            "Vertical"
          ];

          resizeDirection = [
            "Inwards"
            "Outwards"
          ];

          # NOTE: Unused but kept since it might be useful in the future
          # deadnix: skip
          resizeEdge = [
            "Bottom"
            "BottomLeft"
            "BottomRight"
            "Left"
            "Right"
            "Top"
            "TopLeft"
            "TopRight"
          ];

          system = [
            # Opens the application library
            "AppLibrary"
            # Decreases screen brightness
            "BrightnessDown"
            # Increases screen brightness
            "BrightnessUp"
            # Opens the home folder in a system default file browser
            "HomeFolder"
            # Decreases keyboard brightness
            "KeyboardBrightnessDown"
            # Increases keyboard brightness
            "KeyboardBrightnessUp"
            # Opens the launcher
            "Launcher"
            # Locks the screen
            "LockScreen"
            # Mutes the active audio output
            "Mute"
            # Mutes the active microphone
            "MuteMic"
            # Plays and Pauses audio
            "PlayPause"
            # Goes to the next track
            "PlayNext"
            # Go to the previous track
            "PlayPrev"
            # Takes a screenshot
            "Screenshot"
            # Opens the system default terminal
            "Terminal"
            # Lowers the volume of the active audio output
            "VolumeLower"
            # Raises the volume of the active audio output
            "VolumeRaise"
            # Opens the system default web browser
            "WebBrowser"
            # Opens the (alt+tab) window switcher
            "WindowSwitcher"
            # Opens the (alt+shift+tab) window switcher
            "WindowSwitcherPrevious"
            # Opens the workspace overview
            "WorkspaceOverview"
          ];
        in
        lib.types.submodule {
          options = {
            description = mkNullOrOption {
              type = with lib.types; ronOptionalOf str;
              example = {
                __type = "optional";
                value = "Open Terminal";
              };
              description = ''
                A description for the shortcut.
                Used by COSMIC Settings to display the name of a custom shortcut.
                This field is optional, and should only be used when defining custom shortcuts.
              '';
            };
            key = lib.mkOption {
              type = lib.types.str;
              example = "Super+Q";
              description = ''
                The key combination that triggers the action.
                For example, "Super+Q" would trigger the action when the Super and Q keys are pressed together.
              '';
            };
            action = lib.mkOption {
              type =
                with lib.types;
                oneOf [
                  (ronEnum enumVariants)
                  (ronTupleEnumOf (ronEnum direction) [
                    # Migrate the active workspace to the output in the given direction
                    "MigrateWorkspaceToOutput"
                    # Move a window in the given direction
                    "Move"
                    # Move a window to the given output
                    "MoveToOutput"
                    # Move a window to the output in the given direction
                    "SendToOutput"
                    # Move to an output in the given direction
                    "SwitchOutput"
                  ])
                  (ronTupleEnumOf ints.u8 [
                    # Move a window to the given workspace
                    "MoveToWorkspace"
                    # Move a window to the given workspace
                    "SendToWorkspace"
                    # Change focus to the given workspace ID
                    "Workspace"
                  ])
                  (ronTupleEnumOf (ronEnum focusDirection)
                    # Change focus to the window or workspace in the given direction
                    [ "Focus" ]
                  )
                  (ronTupleEnumOf (ronEnum orientation)
                    # Change the orientation of a tiling group
                    [ "Orientation" ]
                  )
                  (ronTupleEnumOf (ronEnum resizeDirection)
                    # Resize the active window in a given direction
                    [ "Resizing" ]
                  )
                  (ronTupleEnumOf (ronEnum system)
                    # Perform a common system operation
                    [ "System" ]
                  )
                  (ronTupleEnumOf str
                    # Execute a command with any given arguments
                    [ "Spawn" ]
                  )
                ];
              example = {
                __type = "enum";
                variant = "Spawn";
                value = [ "firefox" ];
              };
              description = ''
                The action triggered by the shortcut.
                Actions can include running a command, moving windows, system actions, and more.
              '';
            };
          };
        };
    in
    mkNullOrOption {
      type = lib.types.listOf shortcutSubmodule;
      example = [
        {
          description = "Open Firefox";
          key = "Super+B";
          action = {
            __type = "enum";
            variant = "Spawn";
            value = [ "firefox" ];
          };
        }
        {
          key = "Super+Q";
          action = {
            __type = "enum";
            variant = "Close";
          };
        }
        {
          key = "Super+M";
          action = {
            __type = "enum";
            variant = "Disable";
          };
        }
        {
          key = "XF86MonBrightnessDown";
          action = {
            __type = "enum";
            variant = "BrightnessDown";
          };
        }
      ];
      description = ''
        Defines a list of custom shortcuts for the COSMIC desktop environment.
        Each shortcut specifies a key combination, the action to be performed, and optionally a description for a custom shortcut.
      '';
    };

  config =
    let
      parseShortcuts =
        key:
        let
          parts = builtins.filter (x: x != "") (lib.splitString "+" key);

          validModifiers = [
            "Alt"
            "Ctrl"
            "Shift"
            "Super"
          ];
        in
        {
          key =
            let
              last = lib.last parts;
            in
            if builtins.stringLength last == 1 then
              lib.toLower last
            else if builtins.elem (capitalizeWord last) validModifiers then
              throw "Key cannot be a modifier"
            else
              last;
          modifiers = map (
            modifier:
            if builtins.elem modifier validModifiers then
              {
                __type = "enum";
                variant = modifier;
              }
            else
              throw "Invalid modifier: ${modifier}. Valid modifiers are: ${builtins.concatStringsSep ", " validModifiers}"
          ) (lib.unique (lib.init parts));
        };
    in
    lib.mkIf (cfg.enable && cfg.shortcuts != null) {
      wayland.desktopManager.cosmic.configFile."com.system76.CosmicSettings.Shortcuts" = {
        entries.custom = {
          __type = "map";
          value = map (shortcut: {
            key = lib.cosmic.utils.cleanNullsExceptOptional (
              parseShortcuts shortcut.key
              // {
                inherit (shortcut) description;
              }
            );
            value = shortcut.action;
          }) cfg.shortcuts;
        };
        version = 1;
      };
    };
}
