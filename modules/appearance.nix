{ config, lib, ... }:
{
  imports = [
    # TODO: Remove after COSMIC stable release.
    (lib.mkRenamedOptionModule
      [ "wayland" "desktopManager" "cosmic" "appearance" "theme" "default" ]
      [ "wayland" "desktopManager" "cosmic" "appearance" "theme" "mode" ]
    )
  ];

  options.wayland.desktopManager.cosmic.appearance =
    let
      inherit (lib.cosmic) defaultNullOpts mkRONExpression;
    in
    {
      theme =
        let
          themeSubmodule =
            let
              srgbType = lib.types.submodule {
                options = {
                  red = lib.mkOption {
                    type = with lib.types; maybeRonRaw (numbers.between 0.0 1.0);
                    example = 0.0;
                    description = ''
                      The red component of the color.
                    '';
                  };
                  green = lib.mkOption {
                    type = with lib.types; maybeRonRaw (numbers.between 0.0 1.0);
                    example = 0.0;
                    description = ''
                      The green component of the color.
                    '';
                  };
                  blue = lib.mkOption {
                    type = with lib.types; maybeRonRaw (numbers.between 0.0 1.0);
                    example = 0.0;
                    description = ''
                      The blue component of the color.
                    '';
                  };
                };
              };

              srgbaType = lib.types.submodule {
                options = {
                  red = lib.mkOption {
                    type = with lib.types; maybeRonRaw (numbers.between 0.0 1.0);
                    example = 0.0;
                    description = ''
                      The red component of the color.
                    '';
                  };
                  green = lib.mkOption {
                    type = with lib.types; maybeRonRaw (numbers.between 0.0 1.0);
                    example = 0.0;
                    description = ''
                      The green component of the color.
                    '';
                  };
                  blue = lib.mkOption {
                    type = with lib.types; maybeRonRaw (numbers.between 0.0 1.0);
                    example = 0.0;
                    description = ''
                      The blue component of the color.
                    '';
                  };
                  alpha = lib.mkOption {
                    type = with lib.types; maybeRonRaw (numbers.between 0.0 1.0);
                    example = 0.0;
                    description = ''
                      The alpha component of the color.
                    '';
                  };
                };
              };
            in
            lib.types.submodule {
              freeformType = with lib.types; attrsOf anything;
              options = {
                accent =
                  defaultNullOpts.mkNullable (lib.types.ronOptionalOf srgbType)
                    {
                      __type = "optional";
                      value = {
                        red = 0.0;
                        green = 0.0;
                        blue = 0.0;
                      };
                    }
                    ''
                      Accent color for the theme.
                    '';

                active_hint = defaultNullOpts.mkU32 3 ''
                  Active window hint outline width for COSMIC compositor.
                '';

                bg_color =
                  defaultNullOpts.mkNullable (lib.types.ronOptionalOf srgbaType)
                    {
                      __type = "optional";
                      value = {
                        red = 0.0;
                        green = 0.0;
                        blue = 0.0;
                        alpha = 1.0;
                      };
                    }
                    ''
                      Background color for the theme.
                    '';

                corner_radii =
                  let
                    cornerRadiiSubmodule = lib.types.submodule {
                      freeformType = with lib.types; attrsOf anything;
                      options = {
                        radius_0 = lib.mkOption {
                          type = with lib.types; maybeRonRaw (ronTupleOf float 4);
                          example = mkRONExpression 0 {
                            __type = "tuple";
                            value = [
                              0.0
                              0.0
                              0.0
                              0.0
                            ];
                          } null;
                          description = ''
                            The corner radius of 0.
                          '';
                        };

                        radius_xs = lib.mkOption {
                          type = with lib.types; maybeRonRaw (ronTupleOf float 4);
                          example = mkRONExpression 0 {
                            __type = "tuple";
                            value = [
                              4.0
                              4.0
                              4.0
                              4.0
                            ];
                          } null;
                          description = ''
                            The extra small corner radius.
                          '';
                        };

                        radius_s = lib.mkOption {
                          type = with lib.types; maybeRonRaw (ronTupleOf float 4);
                          example = mkRONExpression 0 {
                            __type = "tuple";
                            value = [
                              8.0
                              8.0
                              8.0
                              8.0
                            ];
                          } null;
                          description = ''
                            The small corner radius.
                          '';
                        };

                        radius_m = lib.mkOption {
                          type = with lib.types; maybeRonRaw (ronTupleOf float 4);
                          example = mkRONExpression 0 {
                            __type = "tuple";
                            value = [
                              16.0
                              16.0
                              16.0
                              16.0
                            ];
                          } null;
                          description = ''
                            The medium corner radius.
                          '';
                        };

                        radius_l = lib.mkOption {
                          type = with lib.types; maybeRonRaw (ronTupleOf float 4);
                          example = mkRONExpression 0 {
                            __type = "tuple";
                            value = [
                              32.0
                              32.0
                              32.0
                              32.0
                            ];
                          } null;
                          description = ''
                            The large corner radius.
                          '';
                        };

                        radius_xl = lib.mkOption {
                          type = with lib.types; maybeRonRaw (ronTupleOf float 4);
                          example = mkRONExpression 0 {
                            __type = "tuple";
                            value = [
                              160.0
                              160.0
                              160.0
                              160.0
                            ];
                          } null;
                          description = ''
                            The extra large corner radius.
                          '';
                        };
                      };
                    };
                  in
                  defaultNullOpts.mkNullable cornerRadiiSubmodule
                    {
                      radius_0 = {
                        __type = "tuple";
                        value = [
                          0.0
                          0.0
                          0.0
                          0.0
                        ];
                      };

                      radius_xs = {
                        __type = "tuple";
                        value = [
                          4.0
                          4.0
                          4.0
                          4.0
                        ];
                      };

                      radius_s = {
                        __type = "tuple";
                        value = [
                          8.0
                          8.0
                          8.0
                          8.0
                        ];
                      };

                      radius_m = {
                        __type = "tuple";
                        value = [
                          16.0
                          16.0
                          16.0
                          16.0
                        ];
                      };

                      radius_l = {
                        __type = "tuple";
                        value = [
                          32.0
                          32.0
                          32.0
                          32.0
                        ];
                      };

                      radius_xl = {
                        __type = "tuple";
                        value = [
                          160.0
                          160.0
                          160.0
                          160.0
                        ];
                      };
                    }
                    ''
                      Corner radii variables for the theme.
                    '';

                destructive =
                  defaultNullOpts.mkNullable (lib.types.ronOptionalOf srgbType)
                    {
                      __type = "optional";
                      value = {
                        red = 1.0;
                        green = 0.0;
                        blue = 0.0;
                      };
                    }
                    ''
                      Destructive color for the theme.
                    '';

                gaps =
                  defaultNullOpts.mkRonTupleOf lib.types.ints.u32 2
                    {
                      __type = "tuple";
                      value = [
                        0
                        8
                      ];
                    }
                    ''
                      Window gaps size (outer and inner, respectively) for COSMIC compositor.
                    '';

                is_frosted = defaultNullOpts.mkBool false ''
                  Whether to enable blurred transparency for COSMIC compositor.

                  NOTE: This option doesn't work for COSMIC yet.
                '';

                neutral_tint =
                  defaultNullOpts.mkNullable (lib.types.ronOptionalOf srgbType)
                    {
                      __type = "optional";
                      value = {
                        red = 0.0;
                        green = 0.0;
                        blue = 0.0;
                      };
                    }
                    ''
                      Neutral tint color for the theme.
                    '';

                palette =
                  let
                    paletteSubmodule = lib.types.submodule {
                      freeformType = with lib.types; attrsOf anything;
                      options = {
                        accent_blue = lib.mkOption {
                          type = lib.types.maybeRonRaw srgbaType;
                          example = {
                            red = 0.0;
                            green = 0.5;
                            blue = 1.0;
                            alpha = 1.0;
                          };
                          description = ''
                            The blue accent color.
                          '';
                        };

                        accent_green = lib.mkOption {
                          type = lib.types.maybeRonRaw srgbaType;
                          example = {
                            red = 0.0;
                            green = 1.0;
                            blue = 0.0;
                            alpha = 1.0;
                          };
                          description = ''
                            The green accent color.
                          '';
                        };

                        accent_indigo = lib.mkOption {
                          type = lib.types.maybeRonRaw srgbaType;
                          example = {
                            red = 0.3;
                            green = 0.0;
                            blue = 0.5;
                            alpha = 1.0;
                          };
                          description = ''
                            The indigo accent color.
                          '';
                        };

                        accent_orange = lib.mkOption {
                          type = lib.types.maybeRonRaw srgbaType;
                          example = {
                            red = 1.0;
                            green = 0.5;
                            blue = 0.0;
                            alpha = 1.0;
                          };
                          description = ''
                            The orange accent color.
                          '';
                        };

                        accent_pink = lib.mkOption {
                          type = lib.types.maybeRonRaw srgbaType;
                          example = {
                            red = 1.0;
                            green = 0.0;
                            blue = 0.5;
                            alpha = 1.0;
                          };
                          description = ''
                            The pink accent color.
                          '';
                        };

                        accent_purple = lib.mkOption {
                          type = lib.types.maybeRonRaw srgbaType;
                          example = {
                            red = 0.5;
                            green = 0.0;
                            blue = 0.5;
                            alpha = 1.0;
                          };
                          description = ''
                            The purple accent color.
                          '';
                        };

                        accent_red = lib.mkOption {
                          type = lib.types.maybeRonRaw srgbaType;
                          example = {
                            red = 1.0;
                            green = 0.0;
                            blue = 0.0;
                            alpha = 1.0;
                          };
                          description = ''
                            The red accent color.
                          '';
                        };

                        accent_warm_grey = lib.mkOption {
                          type = lib.types.maybeRonRaw srgbaType;
                          example = {
                            red = 0.5;
                            green = 0.5;
                            blue = 0.5;
                            alpha = 1.0;
                          };
                          description = ''
                            The warm grey accent color.
                          '';
                        };

                        accent_yellow = lib.mkOption {
                          type = lib.types.maybeRonRaw srgbaType;
                          example = {
                            red = 1.0;
                            green = 1.0;
                            blue = 0.0;
                            alpha = 1.0;
                          };
                          description = ''
                            The yellow accent color.
                          '';
                        };

                        bright_green = lib.mkOption {
                          type = lib.types.maybeRonRaw srgbaType;
                          example = {
                            red = 0.0;
                            green = 1.0;
                            blue = 0.0;
                            alpha = 1.0;
                          };
                          description = ''
                            The bright green color.
                          '';
                        };

                        bright_orange = lib.mkOption {
                          type = lib.types.maybeRonRaw srgbaType;
                          example = {
                            red = 1.0;
                            green = 0.5;
                            blue = 0.0;
                            alpha = 1.0;
                          };
                          description = ''
                            The bright orange color.
                          '';
                        };

                        bright_red = lib.mkOption {
                          type = lib.types.maybeRonRaw srgbaType;
                          example = {
                            red = 1.0;
                            green = 0.0;
                            blue = 0.0;
                            alpha = 1.0;
                          };
                          description = ''
                            The bright red color.
                          '';
                        };

                        ext_blue = lib.mkOption {
                          type = lib.types.maybeRonRaw srgbaType;
                          example = {
                            red = 0.0;
                            green = 0.5;
                            blue = 1.0;
                            alpha = 1.0;
                          };
                          description = ''
                            The blue color of the extended palette.
                          '';
                        };

                        ext_indigo = lib.mkOption {
                          type = lib.types.maybeRonRaw srgbaType;
                          example = {
                            red = 0.3;
                            green = 0.0;
                            blue = 0.5;
                            alpha = 1.0;
                          };
                          description = ''
                            The indigo color of the extended palette.
                          '';
                        };

                        ext_orange = lib.mkOption {
                          type = lib.types.maybeRonRaw srgbaType;
                          example = {
                            red = 1.0;
                            green = 0.5;
                            blue = 0.0;
                            alpha = 1.0;
                          };
                          description = ''
                            The orange color of the extended palette.
                          '';
                        };

                        ext_pink = lib.mkOption {
                          type = lib.types.maybeRonRaw srgbaType;
                          example = {
                            red = 1.0;
                            green = 0.0;
                            blue = 0.5;
                            alpha = 1.0;
                          };
                          description = ''
                            The pink color of the extended palette.
                          '';
                        };

                        ext_purple = lib.mkOption {
                          type = lib.types.maybeRonRaw srgbaType;
                          example = {
                            red = 0.5;
                            green = 0.0;
                            blue = 0.5;
                            alpha = 1.0;
                          };
                          description = ''
                            The purple color of the extended palette.
                          '';
                        };

                        ext_warm_grey = lib.mkOption {
                          type = lib.types.maybeRonRaw srgbaType;
                          example = {
                            red = 0.5;
                            green = 0.5;
                            blue = 0.5;
                            alpha = 1.0;
                          };
                          description = ''
                            The warm grey color of the extended palette.
                          '';
                        };

                        ext_yellow = lib.mkOption {
                          type = lib.types.maybeRonRaw srgbaType;
                          example = {
                            red = 1.0;
                            green = 1.0;
                            blue = 0.0;
                            alpha = 1.0;
                          };
                          description = ''
                            The yellow color of the extended palette.
                          '';
                        };

                        gray_1 = lib.mkOption {
                          type = lib.types.maybeRonRaw srgbaType;
                          example = {
                            red = 0.1;
                            green = 0.1;
                            blue = 0.1;
                            alpha = 1.0;
                          };
                          description = ''
                            The first gray color.
                          '';
                        };

                        gray_2 = lib.mkOption {
                          type = lib.types.maybeRonRaw srgbaType;
                          example = {
                            red = 0.2;
                            green = 0.2;
                            blue = 0.2;
                            alpha = 1.0;
                          };
                          description = ''
                            The second gray color.
                          '';
                        };

                        name = lib.mkOption {
                          type = with lib.types; maybeRonRaw str;
                          example = "cosmic-dark";
                          description = ''
                            The name of the color palette.
                          '';
                        };

                        neutral_0 = lib.mkOption {
                          type = lib.types.maybeRonRaw srgbaType;
                          example = {
                            red = 0.0;
                            green = 0.0;
                            blue = 0.0;
                            alpha = 1.0;
                          };
                          description = ''
                            The first neutral color.
                          '';
                        };

                        neutral_1 = lib.mkOption {
                          type = lib.types.maybeRonRaw srgbaType;
                          example = {
                            red = 0.1;
                            green = 0.1;
                            blue = 0.1;
                            alpha = 1.0;
                          };
                          description = ''
                            The second neutral color.
                          '';
                        };

                        neutral_2 = lib.mkOption {
                          type = lib.types.maybeRonRaw srgbaType;
                          example = {
                            red = 0.2;
                            green = 0.2;
                            blue = 0.2;
                            alpha = 1.0;
                          };
                          description = ''
                            The third neutral color.
                          '';
                        };

                        neutral_3 = lib.mkOption {
                          type = lib.types.maybeRonRaw srgbaType;
                          example = {
                            red = 0.3;
                            green = 0.3;
                            blue = 0.3;
                            alpha = 1.0;
                          };
                          description = ''
                            The fourth neutral color.
                          '';
                        };

                        neutral_4 = lib.mkOption {
                          type = lib.types.maybeRonRaw srgbaType;
                          example = {
                            red = 0.4;
                            green = 0.4;
                            blue = 0.4;
                            alpha = 1.0;
                          };
                          description = ''
                            The fifth neutral color.
                          '';
                        };

                        neutral_5 = lib.mkOption {
                          type = lib.types.maybeRonRaw srgbaType;
                          example = {
                            red = 0.5;
                            green = 0.5;
                            blue = 0.5;
                            alpha = 1.0;
                          };
                          description = ''
                            The sixth neutral color.
                          '';
                        };

                        neutral_6 = lib.mkOption {
                          type = lib.types.maybeRonRaw srgbaType;
                          example = {
                            red = 0.6;
                            green = 0.6;
                            blue = 0.6;
                            alpha = 1.0;
                          };
                          description = ''
                            The seventh neutral color.
                          '';
                        };

                        neutral_7 = lib.mkOption {
                          type = lib.types.maybeRonRaw srgbaType;
                          example = {
                            red = 0.7;
                            green = 0.7;
                            blue = 0.7;
                            alpha = 1.0;
                          };
                          description = ''
                            The eighth neutral color.
                          '';
                        };

                        neutral_8 = lib.mkOption {
                          type = lib.types.maybeRonRaw srgbaType;
                          example = {
                            red = 0.8;
                            green = 0.8;
                            blue = 0.8;
                            alpha = 1.0;
                          };
                          description = ''
                            The ninth neutral color.
                          '';
                        };

                        neutral_9 = lib.mkOption {
                          type = lib.types.maybeRonRaw srgbaType;
                          example = {
                            red = 0.9;
                            green = 0.9;
                            blue = 0.9;
                            alpha = 1.0;
                          };
                          description = ''
                            The tenth neutral color.
                          '';
                        };

                        neutral_10 = lib.mkOption {
                          type = lib.types.maybeRonRaw srgbaType;
                          example = {
                            red = 1.0;
                            green = 1.0;
                            blue = 1.0;
                            alpha = 1.0;
                          };
                          description = ''
                            The eleventh neutral color.
                          '';
                        };
                      };
                    };
                  in
                  defaultNullOpts.mkRonTupleEnumOf paletteSubmodule
                    [
                      "Dark"
                      "HighContrastDark"
                      "HighContrastLight"
                      "Light"
                    ]
                    1
                    {
                      __type = "enum";
                      variant = "Dark";
                      value = [
                        {
                          accent_blue = {
                            red = 0.0;
                            green = 0.5;
                            blue = 1.0;
                            alpha = 1.0;
                          };

                          accent_green = {
                            red = 0.0;
                            green = 1.0;
                            blue = 0.0;
                            alpha = 1.0;
                          };

                          accent_indigo = {
                            red = 0.3;
                            green = 0.0;
                            blue = 0.5;
                            alpha = 1.0;
                          };

                          accent_orange = {
                            red = 1.0;
                            green = 0.5;
                            blue = 0.0;
                            alpha = 1.0;
                          };

                          accent_pink = {
                            red = 1.0;
                            green = 0.0;
                            blue = 0.5;
                            alpha = 1.0;
                          };

                          accent_purple = {
                            red = 0.5;
                            green = 0.0;
                            blue = 0.5;
                            alpha = 1.0;
                          };

                          accent_red = {
                            red = 1.0;
                            green = 0.0;
                            blue = 0.0;
                            alpha = 1.0;
                          };

                          accent_warm_grey = {
                            red = 0.5;
                            green = 0.5;
                            blue = 0.5;
                            alpha = 1.0;
                          };

                          accent_yellow = {
                            red = 1.0;
                            green = 1.0;
                            blue = 0.0;
                            alpha = 1.0;
                          };

                          bright_green = {
                            red = 0.0;
                            green = 1.0;
                            blue = 0.0;
                            alpha = 1.0;
                          };

                          bright_orange = {
                            red = 1.0;
                            green = 0.5;
                            blue = 0.0;
                            alpha = 1.0;
                          };

                          bright_red = {
                            red = 1.0;
                            green = 0.0;
                            blue = 0.0;
                            alpha = 1.0;
                          };

                          ext_blue = {
                            red = 0.0;
                            green = 0.5;
                            blue = 1.0;
                            alpha = 1.0;
                          };

                          ext_indigo = {
                            red = 0.3;
                            green = 0.0;
                            blue = 0.5;
                            alpha = 1.0;
                          };

                          ext_orange = {
                            red = 1.0;
                            green = 0.5;
                            blue = 0.0;
                            alpha = 1.0;
                          };

                          ext_pink = {
                            red = 1.0;
                            green = 0.0;
                            blue = 0.5;
                            alpha = 1.0;
                          };

                          ext_purple = {
                            red = 0.5;
                            green = 0.0;
                            blue = 0.5;
                            alpha = 1.0;
                          };

                          ext_warm_grey = {
                            red = 0.5;
                            green = 0.5;
                            blue = 0.5;
                            alpha = 1.0;
                          };

                          ext_yellow = {
                            red = 1.0;
                            green = 1.0;
                            blue = 0.0;
                            alpha = 1.0;
                          };

                          gray_1 = {
                            red = 0.1;
                            green = 0.1;
                            blue = 0.1;
                            alpha = 1.0;
                          };
                          gray_2 = {
                            red = 0.2;
                            green = 0.2;
                            blue = 0.2;
                            alpha = 1.0;
                          };

                          name = "cosmic-dark";

                          neutral_0 = {
                            red = 0.0;
                            green = 0.0;
                            blue = 0.0;
                            alpha = 1.0;
                          };

                          neutral_1 = {
                            red = 0.1;
                            green = 0.1;
                            blue = 0.1;
                            alpha = 1.0;
                          };

                          neutral_2 = {
                            red = 0.2;
                            green = 0.2;
                            blue = 0.2;
                            alpha = 1.0;
                          };

                          neutral_3 = {
                            red = 0.3;
                            green = 0.3;
                            blue = 0.3;
                            alpha = 1.0;
                          };

                          neutral_4 = {
                            red = 0.4;
                            green = 0.4;
                            blue = 0.4;
                            alpha = 1.0;
                          };

                          neutral_5 = {
                            red = 0.5;
                            green = 0.5;
                            blue = 0.5;
                            alpha = 1.0;
                          };

                          neutral_6 = {
                            red = 0.6;
                            green = 0.6;
                            blue = 0.6;
                            alpha = 1.0;
                          };

                          neutral_7 = {
                            red = 0.7;
                            green = 0.7;
                            blue = 0.7;
                            alpha = 1.0;
                          };

                          neutral_8 = {
                            red = 0.8;
                            green = 0.8;
                            blue = 0.8;
                            alpha = 1.0;
                          };

                          neutral_9 = {
                            red = 0.9;
                            green = 0.9;
                            blue = 0.9;
                            alpha = 1.0;
                          };

                          neutral_10 = {
                            red = 1.0;
                            green = 1.0;
                            blue = 1.0;
                            alpha = 1.0;
                          };
                        }
                      ];
                    }
                    ''
                      The color palette for the theme.
                    '';

                primary_container_bg =
                  defaultNullOpts.mkNullable (lib.types.ronOptionalOf srgbaType)
                    {
                      __type = "optional";
                      value = {
                        red = 0.0;
                        green = 0.0;
                        blue = 0.0;
                        alpha = 1.0;
                      };
                    }
                    ''
                      Primary container background color for the theme.
                    '';

                secondary_container_bg =
                  defaultNullOpts.mkNullable (lib.types.ronOptionalOf srgbaType)
                    {
                      __type = "optional";
                      value = {
                        red = 0.0;
                        green = 0.0;
                        blue = 0.0;
                        alpha = 1.0;
                      };
                    }
                    ''
                      Secondary container background color for the theme.
                    '';

                spacing =
                  let
                    spacingSubmodule = lib.types.submodule {
                      freeformType = with lib.types; attrsOf anything;
                      options = {
                        space_none = lib.mkOption {
                          type = with lib.types; maybeRonRaw ints.u16;
                          example = 0;
                          description = ''
                            The spacing size when there is no spacing.
                          '';
                        };

                        space_xxxs = lib.mkOption {
                          type = with lib.types; maybeRonRaw ints.u16;
                          example = 4;
                          description = ''
                            The extra extra extra small spacing size.
                          '';
                        };

                        space_xxs = lib.mkOption {
                          type = with lib.types; maybeRonRaw ints.u16;
                          example = 8;
                          description = ''
                            The extra extra small spacing size.
                          '';
                        };

                        space_xs = lib.mkOption {
                          type = with lib.types; maybeRonRaw ints.u16;
                          example = 12;
                          description = ''
                            The extra small spacing size.
                          '';
                        };

                        space_s = lib.mkOption {
                          type = with lib.types; maybeRonRaw ints.u16;
                          example = 16;
                          description = ''
                            The small spacing size.
                          '';
                        };

                        space_m = lib.mkOption {
                          type = with lib.types; maybeRonRaw ints.u16;
                          example = 24;
                          description = ''
                            The medium spacing size.
                          '';
                        };

                        space_l = lib.mkOption {
                          type = with lib.types; maybeRonRaw ints.u16;
                          example = 32;
                          description = ''
                            The large spacing size.
                          '';
                        };

                        space_xl = lib.mkOption {
                          type = with lib.types; maybeRonRaw ints.u16;
                          example = 48;
                          description = ''
                            The extra large spacing size.
                          '';
                        };

                        space_xxl = lib.mkOption {
                          type = with lib.types; maybeRonRaw ints.u16;
                          example = 64;
                          description = ''
                            The extra extra large spacing size.
                          '';
                        };

                        space_xxxl = lib.mkOption {
                          type = with lib.types; maybeRonRaw ints.u16;
                          example = 128;
                          description = ''
                            The extra extra extra large spacing size.
                          '';
                        };
                      };
                    };
                  in
                  defaultNullOpts.mkNullable spacingSubmodule
                    {
                      space_none = 0;
                      space_xxxs = 4;
                      space_xxs = 8;
                      space_xs = 12;
                      space_s = 16;
                      space_m = 24;
                      space_l = 32;
                      space_xl = 48;
                      space_xxl = 64;
                      space_xxxl = 128;
                    }
                    ''
                      The spacing for the theme.
                    '';

                success =
                  defaultNullOpts.mkNullable (lib.types.ronOptionalOf srgbType)
                    {
                      __type = "optional";
                      value = {
                        red = 0.0;
                        green = 1.0;
                        blue = 0.0;
                      };
                    }
                    ''
                      Success color for the theme.
                    '';

                text_tint =
                  defaultNullOpts.mkNullable (lib.types.ronOptionalOf srgbType)
                    {
                      __type = "optional";
                      value = {
                        red = 0.0;
                        green = 0.0;
                        blue = 0.0;
                      };
                    }
                    ''
                      Text tint color for the theme.
                    '';

                warning =
                  defaultNullOpts.mkNullable (lib.types.ronOptionalOf srgbType)
                    {
                      __type = "optional";
                      value = {
                        red = 1.0;
                        green = 0.0;
                        blue = 0.0;
                      };
                    }
                    ''
                      Warning color for the theme.
                    '';

                window_hint =
                  defaultNullOpts.mkNullable (lib.types.ronOptionalOf srgbType)
                    {
                      __type = "optional";
                      value = {
                        red = 0.0;
                        green = 0.5;
                        blue = 1.0;
                      };
                    }
                    ''
                      Window hint color for COSMIC compositor.
                    '';
              };
            };
        in
        {
          dark = defaultNullOpts.mkNullable themeSubmodule { active_hint = 3; } ''
            The dark theme to build for COSMIC desktop and applications.
          '';

          mode = defaultNullOpts.mkEnum [ "dark" "light" ] "dark" ''
            The default theme to use for COSMIC desktop and applications.
          '';

          light = defaultNullOpts.mkNullable themeSubmodule { active_hint = 3; } ''
            The light theme to build for COSMIC desktop and applications.
          '';
        };

      toolkit =
        let
          toolkitSubmodule = lib.types.submodule {
            freeformType = with lib.types; attrsOf anything;
            options =
              let
                fontSubmodule = lib.types.submodule {
                  freeformType = with lib.types; attrsOf anything;
                  options = {
                    family = lib.mkOption {
                      type = with lib.types; maybeRonRaw str;
                      example = "Inter";
                      description = ''
                        The font family to use.
                      '';
                    };

                    stretch = lib.mkOption {
                      type =
                        with lib.types;
                        maybeRonRaw (ronEnum [
                          "UltraCondensed"
                          "ExtraCondensed"
                          "Condensed"
                          "SemiCondensed"
                          "Normal"
                          "SemiExpanded"
                          "Expanded"
                          "ExtraExpanded"
                          "UltraExpanded"
                        ]);
                      example = mkRONExpression 0 {
                        __type = "enum";
                        variant = "Normal";
                      } null;
                      description = ''
                        The font stretch to use.
                      '';
                    };

                    style = lib.mkOption {
                      type =
                        with lib.types;
                        maybeRonRaw (ronEnum [
                          "Normal"
                          "Italic"
                          "Oblique"
                        ]);
                      example = mkRONExpression 0 {
                        __type = "enum";
                        variant = "Normal";
                      } null;
                      description = ''
                        The font style to use.
                      '';
                    };

                    weight = lib.mkOption {
                      type =
                        with lib.types;
                        maybeRonRaw (ronEnum [
                          "Thin"
                          "ExtraLight"
                          "Light"
                          "Normal"
                          "Medium"
                          "Semibold"
                          "Bold"
                          "ExtraBold"
                          "Black"
                        ]);
                      example = mkRONExpression 0 {
                        __type = "enum";
                        variant = "Normal";
                      } null;
                      description = ''
                        The font weight to use.
                      '';
                    };
                  };
                };
              in
              {
                apply_theme_global = defaultNullOpts.mkBool false ''
                  Whether to apply the theme to other toolkits (GTK, etc.).
                '';

                header_size = defaultNullOpts.mkRonEnum [ "Compact" "Spacious" "Standard" ] "Standard" ''
                  The header size for COSMIC desktop and applications.
                '';

                icon_theme = defaultNullOpts.mkStr "Cosmic" ''
                  The icon theme to use for COSMIC desktop and applications.
                '';

                interface_density = defaultNullOpts.mkRonEnum [ "Compact" "Spacious" "Standard" ] "Standard" ''
                  The interface density to use for COSMIC desktop and applications.
                '';

                interface_font =
                  defaultNullOpts.mkNullable fontSubmodule
                    {
                      family = "Inter";
                      stretch = {
                        __type = "enum";
                        variant = "Normal";
                      };
                      style = {
                        __type = "enum";
                        variant = "Normal";
                      };
                      weight = {
                        __type = "enum";
                        variant = "Normal";
                      };
                    }
                    ''
                      The interface font to use for COSMIC desktop and applications.
                    '';

                monospace_font =
                  defaultNullOpts.mkNullable fontSubmodule
                    {
                      family = "JetBrains Mono";
                      stretch = {
                        __type = "enum";
                        variant = "Normal";
                      };
                      style = {
                        __type = "enum";
                        variant = "Normal";
                      };
                      weight = {
                        __type = "enum";
                        variant = "Normal";
                      };
                    }
                    ''
                      The monospace font to use for COSMIC desktop and applications.
                    '';

                show_maximize = defaultNullOpts.mkBool true ''
                  Whether to show the maximize button in the window title bar.
                '';

                show_minimize = defaultNullOpts.mkBool true ''
                  Whether to show the minimize button in the window title bar.
                '';
              };
          };
        in
        defaultNullOpts.mkNullable toolkitSubmodule
          {
            apply_theme_global = false;
            icon_theme = "Cosmic";
          }
          ''
            The toolkit configuration for COSMIC desktop and applications.
          '';
    };

  config =
    let
      cfg = config.wayland.desktopManager.cosmic;
      version = 1;
    in
    {
      home.activation.buildCosmicTheme =
        let
          needsBuild =
            cfg.panels != null
            && builtins.any (panel: panel.background != null && panel.background.variant == "Color") cfg.panels
            || cfg.appearance.theme.dark != null
            || cfg.appearance.theme.light != null;
        in
        lib.mkIf needsBuild (
          lib.hm.dag.entryAfter [
            "configureCosmic"
          ] "run ${lib.getExe config.programs.cosmic-manager.package} build-theme"
        );

      wayland.desktopManager.cosmic.configFile = lib.mkMerge [
        (lib.mkIf (cfg.appearance.theme.dark != null) {
          "com.system76.CosmicTheme.Dark.Builder" = {
            entries = cfg.appearance.theme.dark;
            inherit version;
          };
        })

        (lib.mkIf (cfg.appearance.theme.light != null) {
          "com.system76.CosmicTheme.Light.Builder" = {
            entries = cfg.appearance.theme.light;
            inherit version;
          };
        })

        (lib.mkIf (cfg.appearance.theme.mode != null) {
          "com.system76.CosmicTheme.Mode" = {
            entries.is_dark = cfg.appearance.theme.mode == "dark";
            inherit version;
          };
        })

        (lib.mkIf (cfg.appearance.toolkit != null) {
          "com.system76.CosmicTk" = {
            entries = cfg.appearance.toolkit;
            inherit version;
          };
        })
      ];
    };
}
