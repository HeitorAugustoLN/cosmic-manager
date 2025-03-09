{ lib, ... }:
let
  inherit (builtins)
    all
    attrNames
    concatLists
    elem
    elemAt
    filter
    foldl'
    fromJSON
    head
    isAttrs
    isFunction
    isList
    isPath
    isString
    length
    mapAttrs
    match
    stringLength
    tail
    zipAttrsWith
    ;
  inherit (lib)
    assertMsg
    concatMapStringsSep
    defaultFunctor
    filterAttrs
    imap1
    mergeDefinitions
    mkOption
    mkOptionType
    showOption
    splitString
    trim
    types
    unique
    warn
    ;
  inherit (lib.cosmic) mkRONExpression;
  inherit (lib.options) mergeEqualOption showDefs;

  rawRon = mkOptionType {
    check =
      value:
      let
        keys = attrNames value;
      in
      isAttrs value
      &&
        [
          "__type"
          "value"
        ] == keys
      && value.__type == "raw"
      && isString value.value;
    description = "raw RON value";
    descriptionClass = "noun";
    emptyValue = {
      value = {
        __type = "raw";
        value = "";
      };
    };
    merge = mergeEqualOption;
    name = "rawRon";
  };
in
{
  inherit rawRon;

  cosmicComponent = types.submodule {
    options = {
      version = mkOption {
        type = types.ints.unsigned;
        example = 1;
        description = ''
          Schema version number for the component configuration.
        '';
      };

      entries = mkOption {
        type = with types; attrsOf anything;
        example = mkRONExpression 0 {
          autotile = true;
          autotile_behavior = {
            __type = "enum";
            variant = "PerWorkspace";
          };
        } null;
        description = ''
          Configuration entries for the component.
        '';
      };
    };
  };

  hexColor = types.strMatching "^#?([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$" // {
    description = "hex color";
  };

  maybeRonRaw =
    elemType:
    let
      ronFirst = types.either rawRon elemType;
      elemFirst = types.either elemType rawRon;
    in
    ronFirst
    // {
      name = "maybeRonRaw";
      inherit (elemFirst) description;
    };

  ronArrayOf =
    elemType: size:
    with types;
    addCheck (listOf elemType) (x: length x == size)
    // {
      description = "list of ${
        optionDescriptionPhrase (class: class == "noun" || class == "composite") elemType
      } with a fixed-size of ${toString size} elements";
    };

  ronChar = mkOptionType {
    check =
      value:
      let
        keys = attrNames value;
      in
      isAttrs value
      &&
        [
          "__type"
          "value"
        ] == keys
      && value.__type == "char"
      && isString value.value
      && stringLength value.value == 1;
    description = "RON char";
    descriptionClass = "noun";
    merge = mergeEqualOption;
    name = "ronChar";
  };

  ronEnum =
    let
      ronEnum' =
        variants:
        let
          name = "ronEnum";
          show = v: ''"${v}"'';
        in
        assert assertMsg (all isString variants) "All variants in the enum must be strings.";
        mkOptionType {
          check =
            value:
            let
              keys = attrNames value;
            in
            isAttrs value
            &&
              [
                "__type"
                "variant"
              ] == keys
            && value.__type == "enum"
            && elem value.variant variants;
          description =
            if variants == [ ] then
              "impossible (empty RON enum)"
            else if length variants == 1 then
              "RON enum variant ${show (head variants)} (singular RON enum)"
            else
              "one of the following RON enum variants: ${concatMapStringsSep ", " show variants}";
          descriptionClass = if length variants < 2 then "noun" else "conjunction";
          functor = defaultFunctor name // {
            payload = { inherit variants; };
            type = payload: ronEnum' payload.variants;
            binOp = a: b: { variants = unique (a.variants + b.variants); };
          };
          merge = mergeEqualOption;
          inherit name;
        };
    in
    ronEnum';

  ronMap = mkOptionType {
    check =
      value:
      let
        keys = attrNames value;
      in
      isAttrs value
      &&
        [
          "__type"
          "value"
        ] == keys
      && value.__type == "map"
      && isList value.value
      && all (
        entry:
        isAttrs entry
        &&
          attrNames entry == [
            "key"
            "value"
          ]
      ) value.value;
    description = "RON map";
    descriptionClass = "noun";
    emptyValue = {
      value = {
        __type = "map";
        value = [ ];
      };
    };
    merge = _loc: defs: {
      __type = "map";
      value = concatLists (map (def: def.value.value) defs);
    };
    name = "ronMap";
  };

  ronMapOf =
    let
      ronMapOf' =
        let
          name = "ronMapOf";
        in
        elemType:
        mkOptionType {
          check =
            value:
            let
              keys = attrNames value;
            in
            isAttrs value
            &&
              [
                "__type"
                "value"
              ] == keys
            && value.__type == "map"
            && isList value.value
            && all (
              entry:
              isAttrs entry
              &&
                attrNames entry == [
                  "key"
                  "value"
                ]
            ) value.value;
          description = "RON map of ${
            types.optionDescriptionPhrase (class: class == "noun" || class == "composite") elemType
          }";
          descriptionClass = "composite";
          emptyValue = {
            value = {
              __type = "map";
              value = [ ];
            };
          };
          functor = defaultFunctor name // {
            binOp =
              a: b:
              let
                merged = a.elemType.typeMerge b.elemType.functor;
              in
              if merged == null then null else { elemType = merged; };
            payload = { inherit elemType; };
            type = payload: ronMapOf' payload.elemType;
            wrappedDeprecationMessage =
              { loc }:
              warn ''
                The deprecated `type.functor.wrapped` attribute of the option `${showOption loc}` is accessed, use `type.nestedTypes.elemType` instead.
              '' elemType;
          };
          inherit (elemType) getSubModules;
          getSubOptions =
            prefix:
            elemType.getSubOptions (
              prefix
              ++ [
                "*"
                "value"
              ]
            );
          merge = loc: defs: {
            __type = "map";
            value = concatLists (
              imap1 (
                n: def:
                imap1 (m: entry: {
                  inherit (entry) key;
                  value =
                    (mergeDefinitions
                      (
                        loc
                        ++ [
                          "[definition ${toString n}-entry ${toString m}]"
                          "value"
                        ]
                      )
                      elemType
                      [
                        {
                          inherit (def) file;
                          inherit (entry) value;
                        }
                      ]
                    ).mergedValue;
                }) def.value.value
              ) defs
            );
          };
          inherit name;
          nestedTypes.elemType = elemType;
          substSubModules = m: ronMapOf' (elemType.substSubModules m);
        };
    in
    ronMapOf';

  ronNamedStruct = mkOptionType {
    check =
      value:
      let
        keys = attrNames value;
      in
      isAttrs value
      &&
        [
          "__type"
          "name"
          "value"
        ] == keys
      && value.__type == "namedStruct"
      && isString value.name
      && isAttrs value.value;
    description = "RON named struct";
    descriptionClass = "noun";
    merge = mergeEqualOption;
    name = "ronNamedStruct";
  };

  ronNamedStructOf =
    let
      ronNamedStructOf' =
        let
          name = "ronNamedStructOf";
        in
        elemType:
        mkOptionType {
          check =
            value:
            let
              keys = attrNames value;
            in
            isAttrs value
            &&
              [
                "__type"
                "name"
                "value"
              ] == keys
            && value.__type == "namedStruct"
            && isString value.name
            && isAttrs value.value;
          description = "RON named struct of ${
            types.optionDescriptionPhrase (class: class == "noun" || class == "composite") elemType
          }";
          descriptionClass = "composite";
          functor = defaultFunctor name // {
            binOp =
              a: b:
              let
                merged = a.elemType.typeMerge b.elemType.functor;
              in
              if merged == null then null else { elemType = merged; };
            payload = { inherit elemType; };
            type = payload: ronNamedStructOf' payload.elemType;
            wrappedDeprecationMessage =
              { loc }:
              warn ''
                The deprecated `type.functor.wrapped` attribute of the option `${showOption loc}` is accessed, use `type.nestedTypes.elemType` instead.
              '' elemType;
          };
          inherit (elemType) getSubModules;
          getSubOptions = prefix: elemType.getSubOptions (prefix ++ [ "<name>" ]);
          merge =
            loc: defs:
            let
              pushPositions = map (
                def:
                mapAttrs (_n: v: {
                  inherit (def) file;
                  value = v;
                }) def.value.value
              );
            in
            {
              __type = "namedStruct";
              name =
                if length defs == 0 then
                  abort "This case should not happen."
                else if length defs == 1 then
                  (head defs).value.name
                else
                  foldl' (
                    first: def:
                    if def.value.name != first.value.name then
                      throw "The option '${showOption loc}' has conflicting definition values: ${
                        showDefs [
                          first
                          def
                        ]
                      }"
                    else
                      first.value.name
                  ) (head defs) (tail defs);
              value = mapAttrs (_n: v: v.value) (
                filterAttrs (_n: v: v ? value) (
                  zipAttrsWith (name: defs: (mergeDefinitions (loc ++ [ name ]) elemType defs).optionalValue) (
                    pushPositions defs
                  )
                )
              );
            };
          inherit name;
          nestedTypes.elemType = elemType;
          substSubModules = m: ronNamedStructOf' (elemType.substSubModules m);
        };
    in
    ronNamedStructOf';

  ronOptional = mkOptionType {
    check =
      value:
      let
        keys = attrNames value;
      in
      isAttrs value
      &&
        [
          "__type"
          "value"
        ] == keys
      && value.__type == "optional"
      && !isFunction value.value
      && !isPath value.value;
    description = "RON optional";
    descriptionClass = "noun";
    merge = mergeEqualOption;
    name = "ronOptional";
  };

  ronOptionalOf =
    let
      ronOptionalOf' =
        let
          name = "ronOptionalOf";
        in
        elemType:
        mkOptionType {
          check =
            value:
            let
              keys = attrNames value;
            in
            isAttrs value
            &&
              [
                "__type"
                "value"
              ] == keys
            && value.__type == "optional"
            && !isFunction value.value
            && !isPath value.value;
          description = "RON optional of ${
            types.optionDescriptionPhrase (class: class == "noun" || class == "composite") elemType
          }";
          descriptionClass = "composite";
          functor = defaultFunctor name // {
            binOp =
              a: b:
              let
                merged = a.elemType.typeMerge b.elemType.functor;
              in
              if merged == null then null else { elemType = merged; };
            payload = { inherit elemType; };
            type = payload: ronOptionalOf' payload.elemType;
            wrappedDeprecationMessage =
              { loc }:
              warn ''
                The deprecated `type.functor.wrapped` attribute of the option `${showOption loc}` is accessed, use `type.nestedTypes.elemType` instead.
              '' elemType;
          };
          inherit (elemType) getSubModules getSubOptions;
          merge = loc: defs: {
            __type = "optional";
            value =
              (mergeDefinitions loc (types.nullOr elemType) (
                map (def: {
                  inherit (def) file;
                  inherit (def.value) value;
                }) defs
              )).mergedValue;
          };
          inherit name;
          nestedTypes.elemType = elemType;
          substSubModules = m: ronOptionalOf' (elemType.substSubModules m);
        };
    in
    ronOptionalOf';

  ronTuple =
    let
      ronTuple' =
        size:
        let
          name = "ronTuple";
        in
        assert assertMsg (size > 0) "The size must be greater than zero.";
        mkOptionType {
          check =
            value:
            let
              keys = attrNames value;
            in
            isAttrs value
            &&
              [
                "__type"
                "value"
              ] == keys
            && value.__type == "tuple"
            && isList value.value
            && length value.value == size;
          description = "RON tuple";
          descriptionClass = "noun";
          emptyValue = {
            value = {
              __type = "tuple";
              value = [ ];
            };
          };
          functor = defaultFunctor name // {
            payload = { inherit size; };
            type = payload: ronTuple' payload.size;
            binOp = a: b: {
              size = if a.size == b.size then a.size else throw "The tuple sizes do not match.";
            };
          };
          merge = _loc: defs: {
            __type = "tuple";
            value = concatLists (map (x: x.value.value) defs);
          };
          inherit name;
        };
    in
    ronTuple';

  ronTupleEnum =
    let
      ronTupleEnum' =
        let
          name = "ronTupleEnum";
          show = v: ''"${v}"'';
        in
        variants: size:
        assert assertMsg (all isString variants) "All variants in the enum must be strings.";
        assert assertMsg (size > 0) "The size must be greater than zero.";
        mkOptionType {
          check =
            value:
            let
              keys = attrNames value;
            in
            isAttrs value
            &&
              [
                "__type"
                "value"
                "variant"
              ] == keys
            && value.__type == "enum"
            && elem value.variant variants
            && isList value.value
            && length value.value == size;
          description =
            if variants == [ ] then
              "impossible (empty RON tuple enum)"
            else if length variants == 1 then
              "RON enum variant ${show (head variants)} with ${toString size} ${
                if size == 1 then "value (singular RON tuple enum)" else "values (singular RON tuple enum)"
              }"
            else
              "one of the following RON tuple enum variants: ${
                concatMapStringsSep ", " show variants
              } with a value";
          descriptionClass = if length variants < 2 then "noun" else "conjunction";
          functor = defaultFunctor name // {
            payload = { inherit size variants; };
            type = payload: ronTupleEnum' payload.variants payload.size;
            binOp = a: b: {
              variants = unique (a.variants + b.variants);
              size = if a.size == b.size then a.size else throw "The tuple sizes do not match.";
            };
          };
          merge = mergeEqualOption;
          inherit name;
        };
    in
    ronTupleEnum';

  ronTupleEnumOf =
    let
      ronTupleEnumOf' =
        let
          name = "ronTupleEnumOf";
          show = v: ''"${v}"'';
        in
        elemType: variants: size:
        assert assertMsg (all isString variants) "All variants in the enum must be strings.";
        assert assertMsg (size > 0) "The size must be greater than zero.";
        mkOptionType {
          check =
            value:
            let
              keys = attrNames value;
            in
            isAttrs value
            &&
              [
                "__type"
                "value"
                "variant"
              ] == keys
            && value.__type == "enum"
            && elem value.variant variants
            && isList value.value
            && length value.value == size;
          description =
            if variants == [ ] then
              "impossible (empty RON tuple enum)"
            else if length variants == 1 then
              "RON enum variant ${show (head variants)} with ${toString size} ${
                types.optionDescriptionPhrase (class: class == "noun" || class == "composite") elemType
              } ${if size == 1 then "value (singular RON tuple enum)" else "values (singular RON tuple enum)"}"
            else
              "one of the following RON tuple enum variants: ${
                concatMapStringsSep ", " show variants
              } with ${toString size} ${
                types.optionDescriptionPhrase (class: class == "noun" || class == "composite") elemType
              } ${if size == 1 then "value" else "values"}";
          descriptionClass = if length variants < 2 then "noun" else "conjunction";
          functor = defaultFunctor name // {
            payload = { inherit elemType size variants; };
            type = payload: ronTupleEnumOf' payload.elemType payload.variants payload.size;
            binOp = a: b: {
              variants = unique (a.variants + b.variants);
              elemType = a.elemType.typeMerge b.elemType.functor;
              size = if a.size == b.size then a.size else throw "The tuple sizes do not match.";
            };
          };
          inherit (elemType) getSubModules;
          getSubOptions = prefix: elemType.getSubOptions (prefix ++ [ "*" ]);
          merge = loc: defs: {
            __type = "enum";
            value = map (x: x.value) (
              filter (x: x ? value) (
                concatLists (
                  imap1 (
                    n: def:
                    imap1 (
                      m: def':
                      (mergeDefinitions (loc ++ [ "[definition ${toString n}-entry ${toString m}]" ]) elemType [
                        {
                          inherit (def) file;
                          value = def';
                        }
                      ]).optionalValue
                    ) def.value.value
                  ) defs
                )
              )
            );
            variant =
              if length defs == 0 then
                abort "This case should not happen."
              else if length defs == 1 then
                (head defs).value.variant
              else
                foldl' (
                  first: def:
                  if def.value.variant != first.value.variant then
                    throw "The option '${showOption (loc ++ [ "variant" ])}' has conflicting definition values: ${
                      showDefs [
                        first
                        def
                      ]
                    }"
                  else
                    first.value.variant
                ) (head defs) (tail defs);
          };
          inherit name;
          nestedTypes.elemType = elemType;
          substSubModules = m: ronTupleEnumOf' (elemType.substSubModules m) variants size;
        };
    in
    ronTupleEnumOf';

  ronTupleOf =
    let
      ronTupleOf' =
        let
          name = "ronTupleOf";
        in
        elemType: size:
        assert assertMsg (size > 0) "The size must be greater than zero.";
        mkOptionType {
          check =
            value:
            let
              keys = attrNames value;
            in
            isAttrs value
            &&
              [
                "__type"
                "value"
              ] == keys
            && value.__type == "tuple"
            && isList value.value
            && length value.value == size;
          description = "RON tuple of ${
            types.optionDescriptionPhrase (class: class == "noun" || class == "composite") elemType
          } with a fixed-size of ${toString size} elements";
          descriptionClass = "composite";
          emptyValue = {
            value = {
              __type = "tuple";
              value = [ ];
            };
          };
          functor = defaultFunctor name // {
            binOp =
              a: b:
              let
                merged = a.elemType.typeMerge b.elemType.functor;
              in
              if merged == null then
                null
              else
                {
                  elemType = merged;
                  size = if a.size == b.size then a.size else throw "The tuple sizes do not match.";
                };
            payload = { inherit elemType size; };
            type = payload: ronTupleOf' payload.elemType payload.size;
            wrappedDeprecationMessage =
              { loc }:
              warn ''
                The deprecated `type.functor.wrapped` attribute of the option `${showOption loc}` is accessed, use `type.nestedTypes.elemType` instead.
              '' elemType;
          };
          inherit (elemType) getSubModules;
          getSubOptions = prefix: elemType.getSubOptions (prefix ++ [ "*" ]);
          merge = loc: defs: {
            __type = "tuple";
            value = map (x: x.value) (
              filter (x: x ? value) (
                concatLists (
                  imap1 (
                    n: def:
                    imap1 (
                      m: def':
                      (mergeDefinitions (loc ++ [ "[definition ${toString n}-entry ${toString m}]" ]) elemType [
                        {
                          inherit (def) file;
                          value = def';
                        }
                      ]).optionalValue
                    ) def.value.value
                  ) defs
                )
              )
            );
          };
          inherit name;
          nestedTypes.elemType = elemType;
          substSubModules = m: ronTupleOf' (elemType.substSubModules m) size;
        };
    in
    ronTupleOf';

  rustToNixType =
    let
      rustToNixType' =
        type:
        let
          handleOption =
            type:
            let
              matches = match "Option<(.*)>" type;
              innerType = if matches != null then head matches else null;
            in
            if matches != null then types.ronOptionalOf (rustToNixType' innerType) else null;
          handleVec =
            type:
            let
              matches = match "Vec<(.*)>" type;
              innerType = if matches != null then head matches else null;
            in
            if matches != null then types.listOf (rustToNixType' innerType) else null;
          handleArray =
            type:
            let
              matches = match "[[]([^;]+); *([0-9]+)[]]" type;
              innerType = if matches != null then head matches else null;
              size = if matches != null then elemAt matches 1 else null;
            in
            if matches != null then types.ronArrayOf (rustToNixType' innerType) (fromJSON size) else null;
          handleTuple =
            type:
            let
              innerTypes =
                if (match "\\((.*?)\\)" type) != null then
                  let
                    inner = head (match "\\((.*?)\\)" type);
                    types = map trim (splitString "," inner);
                  in
                  filter (x: x != "") types
                else
                  null;
            in
            if innerTypes != null then
              if length innerTypes == 1 then
                types.ronTupleOf (rustToNixType' (head innerTypes)) 1
              else
                with types; ronTupleOf (oneOf (map rustToNixType' innerTypes)) (length innerTypes)
            else
              null;
          handleMap =
            type:
            let
              hashMapMatches = match "HashMap<([^,]*),([^>]*)>" type;
              btreeMapMatches = match "BTreeMap<([^,]*),([^>]*)>" type;

              matches =
                if hashMapMatches != null then
                  hashMapMatches
                else if btreeMapMatches != null then
                  btreeMapMatches
                else
                  null;
              valueType = if matches != null then head (tail matches) else null;
            in
            if matches != null then types.ronMapOf (rustToNixType' valueType) else null;
        in
        if handleOption type != null then
          handleOption type
        else if handleVec type != null then
          handleVec type
        else if handleArray type != null then
          handleArray type
        else if handleTuple type != null then
          handleTuple type
        else if handleMap type != null then
          handleMap type
        else
          {
            "&str" = types.str;
            "bool" = types.bool;
            "char" = types.ronChar;
            "f32" = types.float;
            "f64" = types.float;
            "i8" = types.ints.s8;
            "i16" = types.ints.s16;
            "i32" = types.ints.s32;
            "i64" = types.int;
            "i128" = types.int;
            "isize" = types.int;
            "String" = types.str;
            "u8" = types.ints.u8;
            "u16" = types.ints.u16;
            "u32" = types.ints.u32;
            "u64" = types.ints.unsigned;
            "u128" = types.ints.unsigned;
            "usize" = types.ints.unsigned;
          }
          .${trim type} or (throw "Unsupported type: ${type}");
    in
    rustToNixType';
}
