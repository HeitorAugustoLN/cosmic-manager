{ config, lib, ... }:
{
  options.wayland.desktopManager.cosmic.shortcuts =
    let
      inherit (lib.cosmic) defaultNullOpts;

      shortcutSubmodule =
        let
          generatedActions = lib.importJSON ../generated/actions-for-shortcuts.json;
        in
        lib.types.submodule {
          options = {
            description =
              defaultNullOpts.mkRonOptionalOf lib.types.str
                {
                  __type = "optional";
                  value = "Open Terminal";
                }
                ''
                  A description for the shortcut.
                  Used by COSMIC Settings to display the name of a custom shortcut.
                  This field is optional, and should only be used when defining custom shortcuts.
                '';
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
                maybeRonRaw (
                  oneOf (
                    [
                      (ronEnum (
                        lib.pipe generatedActions [
                          (builtins.getAttr "Actions")
                          (builtins.filter (action: !(builtins.hasAttr "type" action)))
                          (map (action: action.name))
                        ]
                      ))
                    ]
                    ++
                      lib.mapAttrsToList
                        (
                          type: names:
                          let
                            actionDependencies = generatedActions.Dependencies;

                            elemType =
                              let
                                inherit (lib.cosmic) rustToNixType;
                              in
                              if builtins.hasAttr type actionDependencies then
                                ronEnum (map (action: action.name) actionDependencies.${type})
                              else
                                rustToNixType type;
                          in
                          ronTupleEnumOf elemType names 1
                        )
                        (
                          lib.pipe generatedActions [
                            (builtins.getAttr "Actions")
                            (builtins.filter (action: builtins.hasAttr "type" action))
                            (builtins.groupBy (action: action.type))
                            (builtins.mapAttrs (_: actions: map (action: action.name) actions))
                          ]
                        )
                  )
                );
              example =
                let
                  inherit (lib.cosmic) mkRonExpression;
                in
                mkRonExpression 0 {
                  __type = "enum";
                  variant = "Spawn";
                  value = [ "firefox" ];
                } null;
              description = ''
                The action triggered by the shortcut.
                Actions can include running a command, moving windows, system actions, and more.
              '';
            };
          };
        };
    in
    defaultNullOpts.mkNullable (lib.types.listOf shortcutSubmodule)
      [
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
            variant = "System";
            value = [
              {
                __type = "enum";
                variant = "BrightnessDown";
              }
            ];
          };
        }
        {
          key = "Super";
          action = {
            __type = "enum";
            variant = "System";
            value = [
              {
                __type = "enum";
                variant = "Launcher";
              }
            ];
          };
        }
      ]
      ''
        Defines a list of custom shortcuts for the COSMIC desktop environment.
        Each shortcut specifies a key combination, the action to be performed, and optionally a description for a custom shortcut.
      '';

  config =
    let
      cfg = config.wayland.desktopManager.cosmic;

      parseShortcuts =
        key:
        let
          validModifiers = [
            "Alt"
            "Ctrl"
            "Shift"
            "Super"
          ];

          isModifier = part: builtins.elem part validModifiers;

          parts = lib.pipe key [
            (lib.splitString "+")
            (builtins.filter (x: x != ""))
          ];

          init = lib.init parts;
          last = lib.last parts;
        in
        {
          key =
            if builtins.all isModifier parts then
              null
            else if builtins.stringLength last == 1 then
              lib.toLower last
            else
              last;

          modifiers = map (modifier: {
            __type = "enum";
            variant = modifier;
          }) (lib.unique (if builtins.all isModifier parts then parts else init));
        };
    in
    lib.mkIf (cfg.shortcuts != null) {
      wayland.desktopManager.cosmic.configFile."com.system76.CosmicSettings.Shortcuts" = {
        entries.custom = {
          __type = "map";
          value = lib.pipe cfg.shortcuts [
            (map (shortcut: {
              key =
                let
                  inherit (lib.cosmic) cleanNullsExceptOptional;
                in
                lib.pipe shortcut.key [
                  parseShortcuts
                  (parsed: parsed // { inherit (shortcut) description; })
                  cleanNullsExceptOptional
                ];
              value = shortcut.action;
            }))
          ];
        };
        version = 1;
      };
    };
}
