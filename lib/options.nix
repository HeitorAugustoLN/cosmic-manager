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
              __type = "option";
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
              value = {
                key = "value";
              };
            };
            tuple = {
              __type = "tuple";
              value = [
                "a"
                1
              ];
            };
            named_struct = {
              __name = "NamedStruct";
              value = {
                key = "value";
              };
            };
          }
        else
          example;
      inherit description;
    };
}
