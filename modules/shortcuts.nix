{ config, lib, ... }:
let
  inherit (builtins)
    all
    elem
    filter
    getAttr
    groupBy
    hasAttr
    mapAttrs
    stringLength
    ;
  inherit (lib)
    importJSON
    init
    last
    mapAttrsToList
    mkIf
    mkOption
    pipe
    splitString
    toLower
    types
    unique
    ;
  inherit (lib.cosmic) cleanNullsExceptOptional defaultNullOpts mkRONExpression;
  inherit (lib.types) rustToNixType;
in
{
  options.wayland.desktopManager.cosmic.shortcuts =
    let
      shortcutSubmodule =
        let
          generatedActions = importJSON ../generated/actions-for-shortcuts.json;
        in
        types.submodule {
          options = {
            description =
              defaultNullOpts.mkRonOptionalOf types.str
                {
                  __type = "optional";
                  value = "Open Terminal";
                }
                ''
                  A description for the shortcut.
                  Used by COSMIC Settings to display the name of a custom shortcut.
                  This field is optional, and should only be used when defining custom shortcuts.
                '';
            key = mkOption {
              type = types.str;
              example = "Super+Q";
              description = ''
                The key combination that triggers the action.
                For example, "Super+Q" would trigger the action when the Super and Q keys are pressed together.
              '';
            };
            action = mkOption {
              type =
                with types;
                maybeRonRaw (
                  oneOf (
                    [
                      (ronEnum (
                        pipe generatedActions [
                          (getAttr "Actions")
                          (filter (action: !(hasAttr "type" action)))
                          (map (action: action.name))
                          # Remove deprecated actions from the list
                          # TODO: Remove it when it gets removed from actions
                          (filter (
                            action:
                            !(elem action [
                              "MigrateWorkspaceToNextOutput"
                              "MigrateWorkspaceToPreviousOutput"
                              "MoveToNextOutput"
                              "MoveToPreviousOutput"
                              "NextOutput"
                              "PreviousOutput"
                              "SendToNextOutput"
                              "SendToPreviousOutput"
                            ])
                          ))
                        ]
                      ))
                    ]
                    ++
                      mapAttrsToList
                        (
                          type: names:
                          let
                            actionDependencies = generatedActions.Dependencies;

                            elemType =
                              if hasAttr type actionDependencies then
                                ronEnum (map (action: action.name) actionDependencies.${type})
                              else
                                rustToNixType type;
                          in
                          ronTupleEnumOf elemType names 1
                        )
                        (
                          pipe generatedActions [
                            (getAttr "Actions")
                            (filter (action: hasAttr "type" action))
                            (groupBy (action: action.type))
                            (mapAttrs (_: actions: map (action: action.name) actions))
                          ]
                        )
                  )
                );
              example = mkRONExpression 0 {
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
    defaultNullOpts.mkNullable (types.listOf shortcutSubmodule)
      [
        {
          description = {
            __type = "optional";
            value = "Open Firefox";
          };
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

          isModifier = part: elem part validModifiers;

          parts = pipe key [
            (splitString "+")
            (filter (x: x != ""))
          ];
        in
        {
          key =
            if all isModifier parts then
              null
            else if stringLength (last parts) == 1 then
              toLower (last parts)
            else
              last parts;

          modifiers = map (modifier: {
            __type = "enum";
            variant = modifier;
          }) (unique (if all isModifier parts then parts else init parts));
        };
    in
    mkIf (cfg.shortcuts != null) {
      wayland.desktopManager.cosmic.configFile."com.system76.CosmicSettings.Shortcuts" = {
        entries.custom = {
          __type = "map";
          value = map (shortcut: {
            key = pipe shortcut.key [
              parseShortcuts
              (parsed: parsed // { inherit (shortcut) description; })
              cleanNullsExceptOptional
            ];
            value = shortcut.action;
          }) cfg.shortcuts;
        };
        version = 1;
      };
    };
}
