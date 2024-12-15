{ lib, ... }:
{
  cosmicEntryValue =
    with lib.types;
    nullOr (oneOf [
      str
      number
      bool
      (listOf anything)
      (attrsOf anything)
    ]);

  cosmicEntry = lib.types.submodule (
    { config, ... }:
    {
      options = {
        value = lib.mkOption {
          type = lib.types.cosmicEntryValue;
          example = true;
          description = "Value of the entry";
        };
        __type = lib.mkOption {
          type =
            with lib.types;
            nullOr (enum [
              "raw"
              "optional"
              "char"
              "map"
              "tuple"
            ]);
          default = null;
          example = "raw";
          description = "Type of the entry";
        };
        __name = lib.mkOption {
          type = with lib.types; nullOr str;
          default = null;
          description = "Name for named structs";
        };
      };

      config = {
        _module.check = lib.mkIf (config.__type != null && config.__name != null) (
          throw "Cannot specify both type and name in cosmicEntry"
        );
      };
    }
  );

  coercedCosmicEntry =
    with lib.types;
    coercedTo cosmicEntryValue (value: { inherit value; }) cosmicEntry;

  cosmicComponent = lib.types.submodule {
    options = {
      version = lib.mkOption {
        type = lib.types.ints.unsigned;
        default = 1;
        example = 2;
        description = "Version of the configuration schema";
      };

      entries = lib.mkOption {
        type = with lib.types; attrsOf coercedCosmicEntry;
        default = { };
        example = {
          autotile = true;
          autotile_behavior = {
            __type = "raw";
            value = "PerWorkspace";
          };
        };
        description = "Entries of the configuration";
      };
    };
  };
}
