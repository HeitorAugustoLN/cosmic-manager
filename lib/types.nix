{ lib, ... }:
{
  cosmicComponent = lib.types.submodule {
    options = {
      version = lib.mkOption {
        type = lib.types.ints.unsigned;
        default = 1;
        example = 2;
        description = ''
          Schema version number for the component configuration.
        '';
      };

      entries = lib.mkOption {
        type = with lib.types; attrsOf cosmicEntryValue;
        default = { };
        example = {
          autotile = true;
          autotile_behavior = {
            __type = "raw";
            value = "PerWorkspace";
          };
        };
        description = ''
          Configuration entries for the component.
        '';
      };
    };
  };

  cosmicEntryValue =
    with lib.types;
    nullOr (oneOf [
      str
      number
      bool
      (listOf anything)
      (attrsOf anything)
    ]);

  cosmicOption = lib.types.submodule {
    options = {
      __type = lib.mkOption {
        type = lib.types.enum [ "option" ];
        visible = false;
      };
      value = lib.mkOption {
        type = lib.types.cosmicEntryValue;
        visible = false;
      };
    };
  };

  cosmicRaw = lib.types.submodule {
    options = {
      __type = lib.mkOption {
        type = lib.types.enum [ "raw" ];
        visible = false;
      };
      value = lib.mkOption {
        type = lib.types.str;
        visible = false;
      };
    };
  };

  cosmicRawEnum =
    enum:
    lib.types.submodule {
      options = {
        __type = lib.mkOption {
          type = lib.types.enum [ "raw" ];
          visible = false;
        };
        value = lib.mkOption {
          type = lib.types.enum enum;
          visible = false;
        };
      };
    };

  hexColor = lib.types.strMatching "^#?([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$";
}
