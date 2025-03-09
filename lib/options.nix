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
    literalExpression
    mkOption
    optionalAttrs
    types
    ;
  inherit (lib.cosmic)
    isRONType
    mkAssertion
    mkRON
    mkThrow
    ;
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
              mkThrow "mkRONExpression" "enum type must have at least a variant key."
          else if value.__type == "namedStruct" then
            if value ? name && value ? value then
              toRONExpression "namedStruct" {
                inherit (value) name;
                value = mapAttrs (_: v: mkRONExpression' nextIndent v "namedStruct") value.value;
              }
            else
              mkThrow "mkRONExpression" "namedStruct type must have name and value keys."
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
        assert mkAssertion "defaultNullOpts" (!(args ? default)) "unexpected argument `default`.";
        assert mkAssertion "defaultNullOpts" (!(args ? defaultText)) "unexpected argument `defaultText`.";
        args // { default = null; };

      mkAttrs' = args: mkNullableWithRaw' (args // { type = types.attrs; });

      mkAttrsOf' =
        { type, ... }@args: mkNullableWithRaw' (args // { type = with types; attrsOf (maybeRonRaw type); });

      mkBool' = args: mkNullableWithRaw' (args // { type = types.bool; });

      mkEnum' =
        { variants, ... }@args:
        assert mkAssertion "defaultNullOpts.mkEnum'" (isList variants) "`variants` must be a list";
        mkNullableWithRaw' (removeAttrs args [ "variants" ] // { type = types.enum variants; });

      mkFloat' = args: mkNullableWithRaw' (args // { type = types.float; });

      mkHexColor' = args: mkNullableWithRaw' (args // { type = types.hexColor; });

      mkI8' = args: mkNullableWithRaw' (args // { type = types.ints.s8; });

      mkI16' = args: mkNullableWithRaw' (args // { type = types.ints.s16; });

      mkI32' = args: mkNullableWithRaw' (args // { type = types.ints.s32; });

      mkInt' = args: mkNullableWithRaw' (args // { type = types.int; });

      mkListOf' =
        { type, ... }@args: mkNullableWithRaw' (args // { type = with types; listOf (maybeRonRaw type); });

      mkNullable' =
        args:
        mkNullOrOption' (
          processDefaultNullArgs args
          // optionalAttrs (args ? example) {
            example = mkRONExpression 0 args.example null;
          }
        );

      mkNullableWithRaw' = { type, ... }@args: mkNullable' (args // { type = types.maybeRonRaw type; });

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

      mkRonArrayOf' =
        { size, type, ... }@args:
        assert mkAssertion "defaultNullOpts.mkRonArrayOf'" (isInt size) "`size` must be an integer";
        mkNullableWithRaw' (
          removeAttrs args [ "size" ]
          // {
            type = with types; ronArrayOf (maybeRonRaw type) size;
          }
        );

      mkRonChar' = args: mkNullableWithRaw' (args // { type = types.ronChar; });

      mkRonEnum' =
        { variants, ... }@args:
        assert mkAssertion "defaultNullOpts.mkRonEnum'" (isList variants) "`variants` must be a list";
        mkNullableWithRaw' (removeAttrs args [ "variants" ] // { type = types.ronEnum variants; });

      mkRonMap' = args: mkNullableWithRaw' (args // { type = types.ronMap; });

      mkRonMapOf' =
        { type, ... }@args:
        mkNullableWithRaw' (args // { type = with types; ronMapOf (maybeRonRaw type); });

      mkRonNamedStruct' = args: mkNullableWithRaw' (args // { type = types.ronNamedStruct; });

      mkRonNamedStructOf' =
        { type, ... }@args:
        mkNullableWithRaw' (args // { type = with types; ronNamedStructOf (maybeRonRaw type); });

      mkRonOptional' = args: mkNullableWithRaw' (args // { type = types.ronOptional; });

      mkRonOptionalOf' =
        { type, ... }@args:
        mkNullableWithRaw' (args // { type = with types; ronOptionalOf (maybeRonRaw type); });

      mkRonTuple' =
        { size, ... }@args:
        assert mkAssertion "defaultNullOpts.mkRonTuple'" (isInt size) "`size` must be an integer";
        mkNullableWithRaw' (removeAttrs args [ "size" ] // { type = types.ronTuple size; });

      mkRonTupleEnum' =
        { size, variants, ... }@args:
        assert mkAssertion "defaultNullOpts.mkRonTupleEnum'" (isList variants) "`variants` must be a list";
        assert mkAssertion "defaultNullOpts.mkRonTupleEnum'" (isInt size) "`size` must be an integer";
        mkNullableWithRaw' (
          removeAttrs args [
            "size"
            "variants"
          ]
          // {
            type = types.ronTupleEnum variants size;
          }
        );

      mkRonTupleEnumOf' =
        {
          size,
          type,
          variants,
          ...
        }@args:
        assert mkAssertion "defaultNullOpts.mkRonTupleEnumOf'" (isList variants)
          "`variants` must be a list";
        assert mkAssertion "defaultNullOpts.mkRonTupleEnumOf'" (isInt size) "`size` must be an integer";
        mkNullableWithRaw' (
          removeAttrs args [
            "size"
            "variants"
          ]
          // {
            type = with types; ronTupleEnumOf (maybeRonRaw type) variants size;
          }
        );

      mkRonTupleOf' =
        { size, type, ... }@args:
        assert mkAssertion "defaultNullOpts.mkRonTupleOf'" (isInt size) "`size` must be an integer";
        mkNullableWithRaw' (
          removeAttrs args [ "size" ]
          // {
            type = with types; ronTupleOf (maybeRonRaw type) size;
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
        mkRonArrayOf'
        mkRonChar'
        mkRonEnum'
        mkRonMap'
        mkRonMapOf'
        mkRonNamedStruct'
        mkRonNamedStructOf'
        mkRonOptional'
        mkRonOptionalOf'
        mkRonTuple'
        mkRonTupleEnum'
        mkRonTupleEnumOf'
        mkRonTupleOf'
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

      mkRonArrayOf =
        type: size: example: description:
        mkRonArrayOf' {
          inherit
            description
            example
            size
            type
            ;
        };

      mkRonChar = example: description: mkRonChar' { inherit description example; };

      mkRonEnum =
        variants: example: description:
        mkRonEnum' { inherit description example variants; };

      mkRonMap = example: description: mkRonMap' { inherit description example; };

      mkRonMapOf =
        type: example: description:
        mkRonMapOf' { inherit description example type; };

      mkRonNamedStruct = example: description: mkRonNamedStruct' { inherit description example; };

      mkRonNamedStructOf =
        type: example: description:
        mkRonNamedStructOf' { inherit description example type; };

      mkRonOptional = example: description: mkRonOptional' { inherit description example; };

      mkRonOptionalOf =
        type: example: description:
        mkRonOptionalOf' { inherit description example type; };

      mkRonTuple =
        size: example: description:
        mkRonTuple' { inherit description example size; };

      mkRonTupleEnum =
        variants: size: example: description:
        mkRonTupleEnum' {
          inherit
            description
            example
            size
            variants
            ;
        };

      mkRonTupleEnumOf =
        type: variants: size: example: description:
        mkRonTupleEnumOf' {
          inherit
            description
            example
            size
            type
            variants
            ;
        };

      mkRonTupleOf =
        type: size: example: description:
        mkRonTupleOf' {
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
