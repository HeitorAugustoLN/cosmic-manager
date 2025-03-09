{ lib, ... }:
let
  inherit (lib) mkOption types;
  inherit (lib.cosmic) defaultNullOpts mkCosmicApplet mkRONExpression;
in
mkCosmicApplet {
  name = "panel-button";
  identifier = "com.system76.CosmicPanelButton";
  configurationVersion = 1;
  settingsDescription = "Configuration entries for all panel buttons.";

  maintainers = [ lib.maintainers.HeitorAugustoLN ];

  settingsOptions = {
    configs =
      let
        configsSubmodule = types.submodule {
          freeformType = with types; attrsOf anything;
          options.force_presentation = mkOption {
            type =
              with types;
              maybeRonRaw (
                ronOptionalOf (
                  maybeRonRaw (ronEnum [
                    "Icon"
                    "Text"
                  ])
                )
              );
            example = mkRONExpression 0 {
              __type = "optional";
              value = {
                __type = "enum";
                variant = "Icon";
              };
            } null;
            description = ''
              Force the presentation of the buttons on the panel.
            '';
          };
        };
      in
      defaultNullOpts.mkNullable (types.ronMapOf configsSubmodule)
        {
          __type = "map";
          value = [
            {
              key = "Panel";
              value = {
                force_presentation = {
                  __type = "optional";
                  value = {
                    __type = "enum";
                    variant = "Icon";
                  };
                };
              };
            }
            {
              key = "Dock";
              value = {
                force_presentation = {
                  __type = "optional";
                  value = {
                    __type = "enum";
                    variant = "Text";
                  };
                };
              };
            }
          ];
        }
        ''
          Configurations for the panel buttons.
        '';
  };

  settingsExample = {
    configs = {
      __type = "map";
      value = [
        {
          key = "Panel";
          value = {
            force_presentation = {
              __type = "optional";
              value = {
                __type = "enum";
                variant = "Icon";
              };
            };
          };
        }
        {
          key = "Dock";
          value = {
            force_presentation = {
              __type = "optional";
              value = {
                __type = "enum";
                variant = "Text";
              };
            };
          };
        }
      ];
    };
  };
}
