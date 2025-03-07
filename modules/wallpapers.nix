{ config, lib, ... }:
{
  options.wayland.desktopManager.cosmic.wallpapers =
    let
      inherit (lib.cosmic) defaultNullOpts;

      wallpapersSubmodule =
        let
          inherit (lib.cosmic) mkRONExpression;
        in
        lib.types.submodule {
          freeformType = with lib.types; attrsOf anything;
          options = {
            filter_by_theme = lib.mkOption {
              type = with lib.types; maybeRonRaw bool;
              example = true;
              description = ''
                Whether to filter the wallpapers by the active theme.
              '';
            };

            filter_method = lib.mkOption {
              type =
                with lib.types;
                maybeRonRaw (ronEnum [
                  "Lanczos"
                  "Linear"
                  "Nearest"
                ]);
              example = mkRONExpression 0 {
                __type = "enum";
                variant = "Lanczos";
              } null;
            };

            output = lib.mkOption {
              type = with lib.types; maybeRonRaw (either (enum [ "all" ]) str);
              example = "all";
              description = ''
                The output(s) to show the wallpaper.
              '';
            };

            rotation_frequency = lib.mkOption {
              type = with lib.types; maybeRonRaw ints.unsigned;
              example = 600;
              description = ''
                The frequency at which the wallpaper should change in seconds.
              '';
            };

            sampling_method = lib.mkOption {
              type =
                with lib.types;
                maybeRonRaw (ronEnum [
                  "Alphanumeric"
                  "Random"
                ]);
              example = mkRONExpression 0 {
                __type = "enum";
                variant = "Alphanumeric";
              } null;
              description = ''
                The method to use for sampling the wallpapers.
              '';
            };

            scaling_mode = lib.mkOption {
              type =
                with lib.types;
                maybeRonRaw (
                  either (ronEnum [
                    "Stretch"
                    "Zoom"
                  ]) (ronTupleEnumOf (ronTupleOf (maybeRonRaw (numbers.between 0.0 1.0)) 3) [ "Fit" ] 1)
                );
              example = mkRONExpression 0 {
                __type = "enum";
                variant = "Fit";
                value = [
                  {
                    __type = "tuple";
                    value = [
                      0.5
                      1.0
                      {
                        __type = "raw";
                        value = "0.345354352";
                      }
                    ];
                  }
                ];
              } null;
            };

            source =
              let
                gradientSubmodule = lib.types.submodule {
                  freeformType = with lib.types; attrsOf anything;
                  options = {
                    colors = lib.mkOption {
                      type =
                        with lib.types;
                        maybeRonRaw (listOf (maybeRonRaw (ronTupleOf (maybeRonRaw (numbers.between 0.0 1.0)) 3)));
                      example = mkRONExpression 0 [
                        {
                          __type = "tuple";
                          value = [
                            0.0
                            0.0
                            0.0
                          ];
                        }
                        {
                          __type = "tuple";
                          value = [
                            1.0
                            1.0
                            1.0
                          ];
                        }
                      ] null;
                    };

                    radius = lib.mkOption {
                      type = with lib.types; maybeRonRaw float;
                      example = 0.0;
                      description = ''
                        The radius of the gradient.
                      '';
                    };
                  };
                };
              in
              lib.mkOption {
                type =
                  with lib.types;
                  maybeRonRaw (
                    either (ronTupleEnumOf (maybeRonRaw str) [ "Path" ] 1) (
                      ronTupleEnumOf (either (ronTupleEnumOf gradientSubmodule [ "Gradient" ] 1) (
                        ronTupleEnumOf (maybeRonRaw (ronTupleOf (maybeRonRaw float) 3)) [ "Single" ] 1
                      )) [ "Color" ] 1
                    )
                  );
                example = mkRONExpression 0 {
                  __type = "enum";
                  variant = "Color";
                  value = [
                    {
                      __type = "enum";
                      variant = "Gradient";
                      value = [
                        {
                          colors = [
                            {
                              __type = "tuple";
                              value = [
                                0.0
                                0.0
                                0.0
                              ];
                            }
                            {
                              __type = "tuple";
                              value = [
                                1.0
                                1.0
                                1.0
                              ];
                            }
                          ];
                          radius = 180.0;
                        }
                      ];
                    }
                  ];
                } null;
                description = ''
                  The source of the wallpaper.
                '';
              };
          };
        };
    in
    defaultNullOpts.mkNullable (lib.types.listOf wallpapersSubmodule)
      [
        {
          output = "all";
          source = {
            __type = "enum";
            variant = "Path";
            value = [ "/path/to/wallpaper.png" ];
          };
          filter_by_theme = true;
          filter_method = {
            __type = "enum";
            variant = "Lanczos";
          };
          scaling_mode = {
            __type = "enum";
            variant = "Fit";
            value = [
              {
                __type = "tuple";
                value = [
                  0.5
                  1.0
                  {
                    __type = "raw";
                    value = "0.345354352";
                  }
                ];
              }
            ];
          };
          sampling_method = {
            __type = "enum";
            variant = "Alphanumeric";
          };
          rotation_frequency = 600;
        }
      ]
      ''
        List of wallpapers to be used in COSMIC.
      '';

  config =
    let
      cfg = config.wayland.desktopManager.cosmic;
      version = 1;

      hasAllWallpaper =
        lib.pipe cfg.wallpapers [
          (builtins.filter (wallpaper: wallpaper.output == "all"))
          builtins.length
        ] > 0;

      outputs = map (wallpaper: wallpaper.output) cfg.wallpapers;
    in
    lib.mkIf (cfg.wallpapers != null) (
      lib.mkMerge [
        {
          assertions = [
            {
              assertion = hasAllWallpaper -> builtins.length cfg.wallpapers == 1;
              message = "Only one wallpaper can be set if the output is set to 'all'.";
            }
            {
              assertion = builtins.length outputs == builtins.length (lib.unique outputs);
              message = "Each output can only have one wallpaper configuration.";
            }
          ];

          wayland.desktopManager.cosmic.configFile."com.system76.CosmicBackground" = {
            entries =
              if hasAllWallpaper then
                {
                  all = builtins.head cfg.wallpapers;
                  same-on-all = true;
                }
              else
                {
                  backgrounds = outputs;
                  same-on-all = false;
                }
                // builtins.listToAttrs (
                  map (wallpaper: {
                    name = "output.${wallpaper.output}";
                    value = wallpaper;
                  }) cfg.wallpapers
                );
            inherit version;
          };
        }

        (lib.mkIf (!hasAllWallpaper) {
          wayland.desktopManager.cosmic.stateFile."com.system76.CosmicBackground" = {
            entries.wallpapers = map (wallpaper: {
              __type = "tuple";
              value = [
                wallpaper.output
                wallpaper.source
              ];
            }) cfg.wallpapers;
            inherit version;
          };
        })
      ]
    );
}
