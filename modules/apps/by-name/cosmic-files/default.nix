{ lib, ... }:
lib.cosmic.applications.mkCosmicApplication {
  name = "cosmic-files";
  originalName = "COSMIC Files";
  identifier = "com.system76.CosmicFiles";
  configurationVersion = 1;

  maintainers = [ lib.maintainers.HeitorAugustoLN ];

  settingsOptions =
    let
      inherit (lib.cosmic) defaultNullOpts;
    in
    {
      app_theme =
        defaultNullOpts.mkRonEnum [ "Dark" "Light" "System" ]
          {
            __type = "enum";
            variant = "System";
          }
          ''
            The theme of the application.
          '';

      desktop =
        defaultNullOpts.mkNullable
          (lib.types.submodule {
            freeformType = with lib.types; attrsOf cosmicEntryValue;
            options = {
              show_content = lib.mkOption {
                type = with lib.types; maybeRonRaw bool;
                example = true;
                description = ''
                  Whether to show the content of the Desktop folder.
                '';
              };

              show_mounted_drives = lib.mkOption {
                type = with lib.types; maybeRonRaw bool;
                example = false;
                description = ''
                  Whether to show mounted drives on the Desktop.
                '';
              };

              show_trash = lib.mkOption {
                type = with lib.types; maybeRonRaw bool;
                example = false;
                description = ''
                  Whether to show the Trash on the Desktop.
                '';
              };
            };
          })
          {
            show_content = true;
            show_mounted_drives = false;
            show_trash = false;
          }
          ''
            The desktop icons settings.
          '';

      favorites =
        defaultNullOpts.mkListOf
          (
            with lib.types;
            either (ronEnum [
              "Documents"
              "Downloads"
              "Home"
              "Music"
              "Pictures"
              "Videos"
            ]) (ronTupleEnumOf lib.types.str [ "Path" ] 1)
          )
          [
            {
              __type = "enum";
              variant = "Home";
            }
            {
              __type = "enum";
              variant = "Documents";
            }
            {
              __type = "enum";
              variant = "Downloads";
            }
            {
              __type = "enum";
              variant = "Music";
            }
            {
              __type = "enum";
              variant = "Pictures";
            }
            {
              __type = "enum";
              variant = "Videos";
            }
          ]
          ''
            The list of favorite folders.
          '';

      show_details = defaultNullOpts.mkBool false ''
        Whether to show file details.
      '';

      tab =
        defaultNullOpts.mkNullable
          (lib.types.submodule {
            freeformType = with lib.types; attrsOf cosmicEntryValue;
            options = {
              folders_first = lib.mkOption {
                type = with lib.types; maybeRonRaw bool;
                example = true;
                description = ''
                  Whether to show folders before files.
                '';
              };

              icon_sizes = lib.mkOption {
                type = lib.types.submodule {
                  freeformType = with lib.types; attrsOf cosmicEntryValue;
                  options = {
                    grid = lib.mkOption {
                      type =
                        with lib.types;
                        maybeRonRaw (
                          addCheck ints.u16 (x: x > 0)
                          // {
                            description = "Non-zero unsigned 16-bit integer";
                          }
                        );
                      example = 100;
                      description = ''
                        The size of the icons in the grid view.
                      '';
                    };

                    list = lib.mkOption {
                      type =
                        with lib.types;
                        maybeRonRaw (
                          addCheck ints.u16 (x: x > 0)
                          // {
                            description = "Non-zero unsigned 16-bit integer";
                          }
                        );
                      example = 100;
                      description = ''
                        The size of the icons in the list view.
                      '';
                    };
                  };
                };
                example = {
                  grid = 100;
                  list = 100;
                };
                description = ''
                  The icon sizes of the grid and list views.
                '';
              };

              show_hidden = lib.mkOption {
                type = with lib.types; maybeRonRaw bool;
                example = false;
                description = ''
                  Whether to show hidden files.
                '';
              };

              view = lib.mkOption {
                type =
                  with lib.types;
                  maybeRonRaw (ronEnum [
                    "Grid"
                    "List"
                  ]);
                example =
                  let
                    inherit (lib.cosmic) mkRonExpression;
                  in
                  mkRonExpression 0 {
                    __type = "enum";
                    variant = "List";
                  } null;
                description = ''
                  The default view of the tab.
                '';
              };
            };
          })
          {
            folders_first = true;
            icon_sizes = {
              grid = 100;
              list = 100;
            };
            show_hidden = false;
            view = {
              __type = "enum";
              variant = "List";
            };
          }
          ''
            The tab settings.
          '';
    };

  settingsExample = {
    app_theme = {
      __type = "enum";
      variant = "System";
    };

    desktop = {
      show_content = true;
      show_mounted_drives = false;
      show_trash = false;
    };

    favorites = [
      {
        __type = "enum";
        variant = "Home";
      }
      {
        __type = "enum";
        variant = "Documents";
      }
      {
        __type = "enum";
        variant = "Downloads";
      }
      {
        __type = "enum";
        variant = "Music";
      }
      {
        __type = "enum";
        variant = "Pictures";
      }
      {
        __type = "enum";
        variant = "Videos";
      }
    ];

    show_details = false;

    tab = {
      folders_first = true;
      icon_sizes = {
        grid = 100;
        list = 100;
      };
      show_hidden = false;
      view = {
        __type = "enum";
        variant = "List";
      };
    };
  };
}
