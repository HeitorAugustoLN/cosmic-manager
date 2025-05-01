{ config, lib, ... }:
let
  inherit (builtins)
    any
    filter
    head
    isString
    length
    listToAttrs
    ;
  inherit (lib)
    flatten
    mkIf
    mkMerge
    mkOption
    optionals
    pipe
    types
    unique
    ;
  inherit (lib.cosmic)
    defaultNullOpts
    importRON
    mkAssertions
    mkRONExpression
    mkWarning
    mkWarnings
    ;
in
{
  options.wayland.desktopManager.cosmic.wallpapers =
    let
      wallpapersSubmodule = types.submodule {
        freeformType = with types; attrsOf anything;
        options = {
          filter_by_theme = mkOption {
            type = with types; maybeRonRaw bool;
            example = true;
            description = ''
              Whether to filter the wallpapers by the active theme.
            '';
          };

          filter_method = mkOption {
            type =
              with types;
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

          output = mkOption {
            type = with types; maybeRonRaw (either (enum [ "all" ]) str);
            example = "all";
            description = ''
              The output(s) to show the wallpaper.
            '';
          };

          rotation_frequency = mkOption {
            type = with types; maybeRonRaw ints.unsigned;
            example = 600;
            description = ''
              The frequency at which the wallpaper should change in seconds.
            '';
          };

          sampling_method = mkOption {
            type =
              with types;
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

          scaling_mode = mkOption {
            type =
              with types;
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
              gradientSubmodule = types.submodule {
                freeformType = with types; attrsOf anything;
                options = {
                  colors = mkOption {
                    type =
                      with types;
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

                  radius = mkOption {
                    type = with types; maybeRonRaw float;
                    example = 0.0;
                    description = ''
                      The radius of the gradient.
                    '';
                  };
                };
              };
            in
            mkOption {
              type =
                with types;
                maybeRonRaw (
                  either (ronTupleEnumOf (maybeRonRaw (either str path)) [ "Path" ] 1) (
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
              # TODO: Remove support for strings after COSMIC stable release
              apply =
                value:
                if any isString value.value then
                  mkWarning "wallpapers" "strings as path values is deprecated, please use a path value instead."
                    value
                else
                  value;
            };
        };
      };
    in
    defaultNullOpts.mkNullable (types.listOf wallpapersSubmodule)
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
        pipe cfg.wallpapers [
          (filter (wallpaper: wallpaper.output == "all"))
          length
        ] > 0;

      availableOutputs = pipe (importRON "${config.xdg.stateHome}/cosmic-comp/outputs.ron").config.value [
        (map (entry: entry.key))
        flatten
        (filter (item: item ? connector))
        (filter (item: item ? make -> item.make != "COSMIC"))
        (map (item: item.connector))
      ];

      outputs = map (wallpaper: wallpaper.output) cfg.wallpapers;
    in
    mkIf (cfg.wallpapers != null) (mkMerge [
      {
        assertions = mkAssertions "wallpapers" [
          {
            assertion = hasAllWallpaper -> length cfg.wallpapers == 1;
            message = "When using output = 'all', exactly one wallpaper must be configured. Multiple wallpapers cannot be used with the 'all' setting.";
          }

          {
            assertion = length outputs == length (unique outputs);
            message = "Duplicate display outputs detected in wallpaper configuration. Each display can only have one wallpaper assigned.";
          }
        ];

        wayland.desktopManager.cosmic.configFile."com.system76.CosmicBackground" = {
          entries =
            if hasAllWallpaper then
              {
                all = head cfg.wallpapers;
                same-on-all = true;
              }
            else
              {
                backgrounds = outputs;
                same-on-all = false;
              }
              // listToAttrs (
                map (wallpaper: {
                  name = "output.${wallpaper.output}";
                  value = wallpaper;
                }) cfg.wallpapers
              );

          inherit version;
        };
      }

      (mkIf hasAllWallpaper {
        wayland.desktopManager.cosmic.stateFile."com.system76.CosmicBackground" = {
          entries.wallpapers = map (output: {
            __type = "tuple";
            value = [
              output
              ((head cfg.wallpapers).source)
            ];
          }) availableOutputs;

          inherit version;
        };
      })

      (mkIf (!hasAllWallpaper) {
        warnings = optionals (availableOutputs != outputs) (
          mkWarnings "wallpapers" [
            ''
              Some available display outputs are missing wallpaper configurations.
              These displays will use the system default background instead of your configured wallpapers.''
          ]
        );

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
    ]);
}
