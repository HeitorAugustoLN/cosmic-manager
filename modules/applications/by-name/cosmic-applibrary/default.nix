{ lib, ... }:
let
  inherit (lib) mkOption types;
  inherit (lib.cosmic) defaultNullOpts mkCosmicApplication mkRONExpression;
in
mkCosmicApplication {
  name = "cosmic-applibrary";
  originalName = "COSMIC Application Library";
  identifier = "com.system76.CosmicAppLibrary";
  configurationVersion = 1;

  maintainers = [ lib.maintainers.HeitorAugustoLN ];

  settingsOptions = {
    groups =
      let
        groupsSubmodule = types.submodule {
          freeformType = with types; attrsOf anything;
          options = {
            filter = mkOption {
              type =
                let
                  categorySubmodule = types.submodule {
                    freeformType = with types; attrsOf anything;
                    options = {
                      categories = mkOption {
                        type = with types; maybeRonRaw (listOf str);
                        example = [ "Office" ];
                        description = ''
                          The categories of the group.
                        '';
                      };

                      exclude = mkOption {
                        type = with types; maybeRonRaw (listOf str);
                        example = [ "com.system76.CosmicStore" ];
                        description = ''
                          The applications to exclude from the group.
                        '';
                      };

                      include = mkOption {
                        type = with types; maybeRonRaw (listOf str);
                        example = [ "com.system76.CosmicStore" ];
                        description = ''
                          The applications to include in the group.
                        '';
                      };
                    };
                  };
                in
                with types;
                maybeRonRaw (oneOf [
                  (ronEnum [ "None" ])
                  (ronTupleEnumOf (listOf str) [ "AppIds" ] 1)
                  (ronNamedStructOf categorySubmodule)
                ]);
              example = mkRONExpression 0 {
                __type = "namedStruct";
                name = "Categories";
                value = {
                  categories = [ "Office" ];
                  exclude = [ ];
                  include = [
                    "org.gnome.Totem"
                    "org.gnome.eog"
                    "simple-scan"
                    "thunderbird"
                  ];
                };
              } null;
              description = ''
                The filter of the group.
              '';
            };

            icon = mkOption {
              type = with types; maybeRonRaw str;
              example = "folder-symbolic";
              description = ''
                The icon of the group.
              '';
            };

            name = mkOption {
              type = with types; maybeRonRaw str;
              example = "cosmic-office";
              description = ''
                The name of the group.
              '';
            };
          };
        };
      in
      defaultNullOpts.mkNullable (types.listOf groupsSubmodule)
        [
          {
            name = "cosmic-office";
            icon = "folder-symbolic";
            filter = {
              __type = "namedStruct";
              name = "Categories";
              value = {
                categories = [ "Office" ];
                exclude = [ ];
                include = [
                  "org.gnome.Totem"
                  "org.gnome.eog"
                  "simple-scan"
                  "thunderbird"
                ];
              };
            };
          }
          {
            name = "Games";
            icon = "folder-symbolic";
            filter = {
              __type = "enum";
              variant = "AppIds";
              value = [
                "Counter-Strike 2"
              ];
            };
          }
        ]
        ''
          The groups of applications to display.
        '';
  };

  settingsExample = {
    groups = [
      {
        name = "cosmic-office";
        icon = "folder-symbolic";
        filter = {
          __type = "namedStruct";
          name = "Categories";
          value = {
            categories = [ "Office" ];
            exclude = [ ];
            include = [
              "org.gnome.Totem"
              "org.gnome.eog"
              "simple-scan"
              "thunderbird"
            ];
          };
        };
      }
      {
        name = "Games";
        icon = "folder-symbolic";
        filter = {
          __type = "enum";
          variant = "AppIds";
          value = [
            "Counter-Strike 2"
          ];
        };
      }
    ];
  };
}
