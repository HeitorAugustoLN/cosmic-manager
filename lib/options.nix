# Heavily inspired by nixvim
{ lib, ... }:
let
  inherit (builtins)
    getAttr
    isAttrs
    isInt
    isList
    isString
    mapAttrs
    removeAttrs
    toJSON
    ;
  inherit (lib)
    assertMsg
    literalExpression
    mkOption
    optionalAttrs
    types
    ;
  inherit (lib.cosmic) isRONType mkRON;
  inherit (lib.generators) toPretty;
  inherit (lib.strings) replicate;

  literalRON =
    r:
    let
      raw = mkRON "raw" r;
      expression = ''cosmicLib.cosmic.mkRON "raw" ${toJSON raw.value}'';
    in
    literalExpression expression;

  mkNullOrOption' =
    {
      type,
      default ? null,
      ...
    }@args:
    mkOption (
      args
      // {
        type = types.nullOr type;
        inherit default;
      }
    );

  mkRONExpression =
    let
      mkRONExpression' =
        startIndent: value: previousType:
        let
          nextIndent = startIndent + 1;

          indent = level: replicate level "  ";

          toRONExpression =
            type: value:
            let
              v = nestedRONExpression type value (indent startIndent);
            in
            if previousType == null || previousType == "namedStruct" then
              v
            else
              nestedLiteral "(${v.__pretty v.val})";
        in
        if isRONType value then
          if value.__type == "enum" then
            if value ? variant then
              if value ? value then
                toRONExpression "enum" {
                  inherit (value) variant;
                  value = map (v: mkRONExpression' (nextIndent + 1) v "enum") value.value;
                }
              else
                toRONExpression "enum" value.variant
            else
              throw "lib.cosmic.mkRONExpression: enum type must have at least a variant key."
          else if value.__type == "namedStruct" then
            if value ? name && value ? value then
              toRONExpression "namedStruct" {
                inherit (value) name;
                value = mapAttrs (_: v: mkRONExpression' nextIndent v "namedStruct") value.value;
              }
            else
              throw "lib.cosmic.mkRONExpression: namedStruct type must have name and value keys."
          else if isRONType value.value then
            toRONExpression value.__type (mkRONExpression' startIndent value.value value.__type)
          else if isList value.value then
            toRONExpression value.__type (map (v: mkRONExpression' nextIndent v value.__type) value.value)
          else if isAttrs value.value then
            toRONExpression value.__type (
              mapAttrs (_: v: mkRONExpression' nextIndent v value.__type) value.value
            )
          else
            toRONExpression value.__type value.value
        else if isList value then
          map (v: mkRONExpression' nextIndent v "list") value
        else if isAttrs value then
          mapAttrs (_: v: mkRONExpression' nextIndent v null) value
        else
          value;
    in
    mkRONExpression';

  nestedLiteral = val: {
    __pretty = getAttr "text";
    val = if val._type or null == "literalExpression" then val else literalExpression val;
  };

  nestedRONExpression =
    type: value: indent:
    nestedLiteral (RONExpression type value indent);

  RONExpression =
    type: value: indent:
    literalExpression ''cosmicLib.cosmic.mkRON "${type}" ${
      toPretty {
        allowPrettyValues = true;
        inherit indent;
      } value
    }'';
in
{
  inherit
    literalRON
    mkNullOrOption'
    mkRONExpression
    nestedLiteral
    nestedRONExpression
    RONExpression
    ;

  defaultNullOpts =
    let
      processDefaultNullArgs =
        args:
        assert
          args ? default
          -> abort "defaultNullOpts: unexpected argument `default`. Did you mean `pluginDefault`?";
        assert
          args ? defaultText
          -> abort "defaultNullOpts: unexpected argument `defaultText`. Did you mean `pluginDefault`?";
        args // { default = null; };

      mkAttrs' = args: mkNullableWithRaw' (args // { type = types.attrs; });

      mkAttrsOf' =
        { type, ... }@args: mkNullableWithRaw' (args // { type = with types; attrsOf (maybeRONRaw type); });

      mkBool' = args: mkNullableWithRaw' (args // { type = types.bool; });

      mkEnum' =
        { variants, ... }@args:
        assert assertMsg (isList variants) "mkEnum': `variants` must be a list";
        mkNullableWithRaw' (removeAttrs args [ "variants" ] // { type = types.enum variants; });

      mkFloat' = args: mkNullableWithRaw' (args // { type = types.float; });

      mkHexColor' = args: mkNullableWithRaw' (args // { type = types.hexColor; });

      mkI8' = args: mkNullableWithRaw' (args // { type = types.ints.s8; });

      mkI16' = args: mkNullableWithRaw' (args // { type = types.ints.s16; });

      mkI32' = args: mkNullableWithRaw' (args // { type = types.ints.s32; });

      mkInt' = args: mkNullableWithRaw' (args // { type = types.int; });

      mkListOf' =
        { type, ... }@args: mkNullableWithRaw' (args // { type = with types; listOf (maybeRONRaw type); });

      mkNullable' =
        args:
        mkNullOrOption' (
          processDefaultNullArgs args
          // optionalAttrs (args ? example) {
            example = mkRONExpression 0 args.example null;
          }
        );

      mkNullableWithRaw' = { type, ... }@args: mkNullable' (args // { type = types.maybeRONRaw type; });

      mkNumber' = args: mkNullableWithRaw' (args // { type = types.number; });

      mkRaw' =
        args:
        mkNullable' (
          args
          // {
            type = types.ronRaw;
          }
          // optionalAttrs (args ? example) {
            example =
              if isString args.example then literalRON args.example else mkRONExpression 0 args.example null;
          }
        );

      mkRONArrayOf' =
        { size, type, ... }@args:
        assert assertMsg (isInt size) "mkRONArrayOf': `size` must be an integer";
        mkNullableWithRaw' (
          removeAttrs args [ "size" ]
          // {
            type = with types; ronArrayOf (maybeRONRaw type) size;
          }
        );

      mkRONChar' = args: mkNullableWithRaw' (args // { type = types.ronChar; });

      mkRONEnum' =
        { variants, ... }@args:
        assert assertMsg (isList variants) "mkRONEnum': `variants` must be a list";
        mkNullableWithRaw' (removeAttrs args [ "variants" ] // { type = types.ronEnum variants; });

      mkRONMap' = args: mkNullableWithRaw' (args // { type = types.ronMap; });

      mkRONMapOf' =
        { type, ... }@args:
        mkNullableWithRaw' (args // { type = with types; ronMapOf (maybeRONRaw type); });

      mkRONNamedStruct' = args: mkNullableWithRaw' (args // { type = types.ronNamedStruct; });

      mkRONNamedStructOf' =
        { type, ... }@args:
        mkNullableWithRaw' (args // { type = with types; ronNamedStructOf (maybeRONRaw type); });

      mkRONOptional' = args: mkNullableWithRaw' (args // { type = types.ronOptional; });

      mkRONOptionalOf' =
        { type, ... }@args:
        mkNullableWithRaw' (args // { type = with types; ronOptionalOf (maybeRONRaw type); });

      mkRONTuple' =
        { size, ... }@args:
        assert assertMsg (isInt size) "mkRONTuple': `size` must be an integer";
        mkNullableWithRaw' (removeAttrs args [ "size" ] // { type = types.ronTuple size; });

      mkRONTupleEnum' =
        { size, variants, ... }@args:
        assert assertMsg (isList variants) "mkRONTupleEnum': `variants` must be a list";
        assert assertMsg (isInt size) "mkRONTupleEnum': `size` must be an integer";
        mkNullableWithRaw' (
          removeAttrs args [
            "size"
            "variants"
          ]
          // {
            type = types.ronTupleEnum variants size;
          }
        );

      mkRONTupleEnumOf' =
        {
          size,
          type,
          variants,
          ...
        }@args:
        assert assertMsg (isList variants) "mkRONTupleEnumOf': `variants` must be a list";
        assert assertMsg (isInt size) "mkRONTupleEnumOf': `size` must be an integer";
        mkNullableWithRaw' (
          removeAttrs args [
            "size"
            "variants"
          ]
          // {
            type = with types; ronTupleEnumOf (maybeRONRaw type) variants size;
          }
        );

      mkRONTupleOf' =
        { size, type, ... }@args:
        assert assertMsg (isInt size) "mkRONTupleOf': `size` must be an integer";
        mkNullableWithRaw' (
          removeAttrs args [ "size" ]
          // {
            type = with types; ronTupleOf (maybeRONRaw type) size;
          }
        );

      mkPositiveInt' = args: mkNullableWithRaw' (args // { type = types.ints.positive; });

      mkStr' = args: mkNullableWithRaw' (args // { type = types.str; });

      mkU8' = args: mkNullableWithRaw' (args // { type = types.ints.u8; });

      mkU16' = args: mkNullableWithRaw' (args // { type = types.ints.u16; });

      mkU32' = args: mkNullableWithRaw' (args // { type = types.ints.u32; });

      mkUnsignedInt' = args: mkNullableWithRaw' (args // { type = types.ints.unsigned; });
    in
    {
      inherit
        mkAttrs'
        mkAttrsOf'
        mkBool'
        mkEnum'
        mkFloat'
        mkHexColor'
        mkI8'
        mkI16'
        mkI32'
        mkInt'
        mkListOf'
        mkNullable'
        mkNullableWithRaw'
        mkNumber'
        mkRaw'
        mkRONArrayOf'
        mkRONChar'
        mkRONEnum'
        mkRONMap'
        mkRONMapOf'
        mkRONNamedStruct'
        mkRONNamedStructOf'
        mkRONOptional'
        mkRONOptionalOf'
        mkRONTuple'
        mkRONTupleEnum'
        mkRONTupleEnumOf'
        mkRONTupleOf'
        mkPositiveInt'
        mkStr'
        mkU8'
        mkU16'
        mkU32'
        mkUnsignedInt'
        ;

      mkAttrs = example: description: mkAttrs' { inherit description example; };

      mkAttrsOf =
        type: example: description:
        mkAttrsOf' { inherit description example type; };

      mkBool = example: description: mkBool' { inherit description example; };

      mkEnum =
        variants: example: description:
        mkEnum' { inherit description example variants; };

      mkFloat = example: description: mkFloat' { inherit description example; };

      mkHexColor = example: description: mkHexColor' { inherit description example; };

      mkI8 = example: description: mkI8' { inherit description example; };

      mkI16 = example: description: mkI16' { inherit description example; };

      mkI32 = example: description: mkI32' { inherit description example; };

      mkInt = example: description: mkInt' { inherit description example; };

      mkListOf =
        type: example: description:
        mkListOf' { inherit description example type; };

      mkNullable =
        type: example: description:
        mkNullable' { inherit description example type; };

      mkNullableWithRaw =
        type: example: description:
        mkNullableWithRaw' { inherit description example type; };

      mkNumber = example: description: mkNumber' { inherit description example; };

      mkRaw = example: description: mkRaw' { inherit description example; };

      mkRONArrayOf =
        type: size: example: description:
        mkRONArrayOf' {
          inherit
            description
            example
            size
            type
            ;
        };

      mkRONChar = example: description: mkRONChar' { inherit description example; };

      mkRONEnum =
        variants: example: description:
        mkRONEnum' { inherit description example variants; };

      mkRONMap = example: description: mkRONMap' { inherit description example; };

      mkRONMapOf =
        type: example: description:
        mkRONMapOf' { inherit description example type; };

      mkRONNamedStruct = example: description: mkRONNamedStruct' { inherit description example; };

      mkRONNamedStructOf =
        type: example: description:
        mkRONNamedStructOf' { inherit description example type; };

      mkRONOptional = example: description: mkRONOptional' { inherit description example; };

      mkRONOptionalOf =
        type: example: description:
        mkRONOptionalOf' { inherit description example type; };

      mkRONTuple =
        size: example: description:
        mkRONTuple' { inherit description example size; };

      mkRONTupleEnum =
        variants: size: example: description:
        mkRONTupleEnum' {
          inherit
            description
            example
            size
            variants
            ;
        };

      mkRONTupleEnumOf =
        type: variants: size: example: description:
        mkRONTupleEnumOf' {
          inherit
            description
            example
            size
            type
            variants
            ;
        };

      mkRONTupleOf =
        type: size: example: description:
        mkRONTupleOf' {
          inherit
            description
            example
            size
            type
            ;
        };

      mkPositiveInt = example: description: mkPositiveInt' { inherit description example; };

      mkStr = example: description: mkStr' { inherit description example; };

      mkU8 = example: description: mkU8' { inherit description example; };

      mkU16 = example: description: mkU16' { inherit description example; };

      mkU32 = example: description: mkU32' { inherit description example; };

      mkUnsignedInt = example: description: mkUnsignedInt' { inherit description example; };
    };

  mkNullOrOption = type: description: mkNullOrOption' { inherit description type; };

  mkSettingsOption =
    {
      description,
      example ? null,
      options ? { },
    }:
    mkOption {
      type =
        with types;
        submodule {
          freeformType = attrsOf anything;
          inherit options;
        };
      default = { };
      example =
        if example == null then
          let
            ex = {
              bool = true;
              char = {
                __type = "char";
                value = "a";
              };
              enum = {
                __type = "enum";
                variant = "FooBar";
              };
              float = 3.14;
              int = 333;
              list = [
                "foo"
                "bar"
                "baz"
              ];
              map = {
                __type = "map";
                value = [
                  {
                    key = "foo";
                    value = "bar";
                  }
                ];
              };
              namedStruct = {
                __type = "namedStruct";
                name = "foo";
                value = {
                  bar = "baz";
                };
              };
              optional = {
                __type = "optional";
                value = "foo";
              };
              raw = {
                __type = "raw";
                value = "foo";
              };
              string = "hello";
              struct = {
                foo = "bar";
              };
              tuple = {
                __type = "tuple";
                value = [
                  "foo"
                  "bar"
                  "baz"
                ];
              };
              tupleEnum = {
                __type = "enum";
                variant = "FooBar";
                value = [ "baz" ];
              };
            };
          in
          mkRONExpression 0 ex null
        else
          mkRONExpression 0 example null;
      inherit description;
    };

  nestedLiteralRON = r: nestedLiteral (literalRON r);
}
