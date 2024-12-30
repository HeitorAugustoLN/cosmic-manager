{ lib, ... }:
{
  mkNullOrOption =
    {
      type,
      default ? null,
      ...
    }@args:
    lib.mkOption (
      args
      // {
        type = lib.types.nullOr type;
        inherit default;
      }
    );

  mkSettingsOption =
    {
      description,
      example ? null,
      options ? { },
    }:
    lib.mkOption {
      type =
        with lib.types;
        submodule {
          freeformType = attrsOf cosmicEntryValue;
          inherit options;
        };
      default = { };
      example =
        if example == null then
          {
            foo = "bar";
            baz = 42;
            optional = {
              __type = "optional";
              value = 3;
            };
            raw = {
              __type = "raw";
              value = "RawValue";
            };
            char = {
              __type = "char";
              value = "c";
            };
            map = {
              __type = "map";
              value = [
                {
                  key = "key";
                  value = "value";
                }
              ];
            };
            tuple = {
              __type = "tuple";
              value = [
                "a"
                1
              ];
            };
            namedStruct = {
              __name = "NamedStruct";
              value = {
                key = "value";
              };
            };
            enum = {
              __type = "enum";
              variant = "ActiveWorkspace";
            };
            tupleEnum = {
              __type = "enum";
              variant = "TupleEnum";
              value = [ "foobar" ];
            };
          }
        else
          example;
      inherit description;
    };
}
