{ lib, ... }:
let
  rawRon = lib.mkOptionType {
    check =
      value:
      let
        keys = builtins.attrNames value;
      in
      builtins.isAttrs value
      &&
        [
          "__type"
          "value"
        ] == keys
      && value.__type == "raw"
      && builtins.isString value.value;
    description = "raw RON value";
    descriptionClass = "noun";
    emptyValue = {
      value = {
        __type = "raw";
        value = "";
      };
    };
    merge = lib.options.mergeEqualOption;
    name = "rawRon";
  };
in
{
  inherit rawRon;

  cosmicComponent = lib.types.submodule {
    options = {
      version = lib.mkOption {
        type = lib.types.ints.unsigned;
        example = 1;
        description = ''
          Schema version number for the component configuration.
        '';
      };

      entries = lib.mkOption {
        type = with lib.types; attrsOf anything;
        example = {
          autotile = true;
          autotile_behavior = {
            __type = "enum";
            variant = "PerWorkspace";
          };
        };
        description = ''
          Configuration entries for the component.
        '';
      };
    };
  };

  hexColor = lib.types.strMatching "^#?([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$" // {
    description = "hex color";
  };

  maybeRonRaw =
    elemType:
    let
      ronFirst = lib.types.either rawRon elemType;
      elemFirst = lib.types.either elemType rawRon;
    in
    ronFirst
    // {
      name = "maybeRonRaw";
      inherit (elemFirst) description;
    };

  ronArrayOf =
    elemType: size:
    with lib.types;
    addCheck (listOf elemType) (x: builtins.length x == size)
    // {
      description = "list of ${
        optionDescriptionPhrase (class: class == "noun" || class == "composite") elemType
      } with a fixed-size of ${toString size} elements";
    };

  ronChar = lib.mkOptionType {
    check =
      value:
      let
        keys = builtins.attrNames value;
      in
      builtins.isAttrs value
      &&
        [
          "__type"
          "value"
        ] == keys
      && value.__type == "char"
      && builtins.isString value.value
      && builtins.stringLength value.value == 1;
    description = "RON char";
    descriptionClass = "noun";
    merge = lib.options.mergeEqualOption;
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
        assert lib.assertMsg (builtins.all (
          value: builtins.isString value
        ) variants) "All variants in the enum must be strings.";
        lib.mkOptionType {
          check =
            value:
            let
              keys = builtins.attrNames value;
            in
            builtins.isAttrs value
            &&
              [
                "__type"
                "variant"
              ] == keys
            && value.__type == "enum"
            && builtins.elem value.variant variants;
          description =
            if variants == [ ] then
              "impossible (empty RON enum)"
            else if builtins.length variants == 1 then
              "RON enum variant ${show (builtins.head variants)} (singular RON enum)"
            else
              "one of the following RON enum variants: ${lib.concatMapStringsSep ", " show variants}";
          descriptionClass = if builtins.length variants < 2 then "noun" else "conjunction";
          functor = lib.defaultFunctor name // {
            payload = { inherit variants; };
            type = payload: ronEnum' payload.variants;
            binOp = a: b: { variants = lib.unique (a.variants + b.variants); };
          };
          merge = lib.options.mergeEqualOption;
          inherit name;
        };
    in
    ronEnum';

  ronMap = lib.mkOptionType {
    check =
      value:
      let
        keys = builtins.attrNames value;
      in
      builtins.isAttrs value
      &&
        [
          "__type"
          "value"
        ] == keys
      && value.__type == "map"
      && builtins.isList value.value
      && builtins.all (
        entry:
        builtins.isAttrs entry
        &&
          builtins.attrNames entry == [
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
      value = builtins.concatLists (map (def: def.value.value) defs);
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
        lib.mkOptionType {
          check =
            value:
            let
              keys = builtins.attrNames value;
            in
            builtins.isAttrs value
            &&
              [
                "__type"
                "value"
              ] == keys
            && value.__type == "map"
            && builtins.isList value.value
            && builtins.all (
              entry:
              builtins.isAttrs entry
              &&
                builtins.attrNames entry == [
                  "key"
                  "value"
                ]
            ) value.value;
          description = "RON map of ${
            lib.types.optionDescriptionPhrase (class: class == "noun" || class == "composite") elemType
          }";
          descriptionClass = "composite";
          emptyValue = {
            value = {
              __type = "map";
              value = [ ];
            };
          };
          functor = lib.defaultFunctor name // {
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
              lib.warn ''
                The deprecated `type.functor.wrapped` attribute of the option `${lib.showOption loc}` is accessed, use `type.nestedTypes.elemType` instead.
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
            value = builtins.concatLists (
              lib.imap1 (
                n: def:
                lib.imap1 (m: entry: {
                  inherit (entry) key;
                  value =
                    (lib.mergeDefinitions
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

  ronNamedStruct = lib.mkOptionType {
    check =
      value:
      let
        keys = builtins.attrNames value;
      in
      builtins.isAttrs value
      &&
        [
          "__type"
          "name"
          "value"
        ] == keys
      && value.__type == "namedStruct"
      && builtins.isString value.name
      && builtins.isAttrs value.value;
    description = "RON named struct";
    descriptionClass = "noun";
    merge = lib.options.mergeEqualOption;
    name = "ronNamedStruct";
  };

  ronNamedStructOf =
    let
      ronNamedStructOf' =
        let
          name = "ronNamedStructOf";
        in
        elemType:
        lib.mkOptionType {
          check =
            value:
            let
              keys = builtins.attrNames value;
            in
            builtins.isAttrs value
            &&
              [
                "__type"
                "name"
                "value"
              ] == keys
            && value.__type == "namedStruct"
            && builtins.isString value.name
            && builtins.isAttrs value.value;
          description = "RON named struct of ${
            lib.types.optionDescriptionPhrase (class: class == "noun" || class == "composite") elemType
          }";
          descriptionClass = "composite";
          functor = lib.defaultFunctor name // {
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
              lib.warn ''
                The deprecated `type.functor.wrapped` attribute of the option `${lib.showOption loc}` is accessed, use `type.nestedTypes.elemType` instead.
              '' elemType;
          };
          inherit (elemType) getSubModules;
          getSubOptions = prefix: elemType.getSubOptions (prefix ++ [ "<name>" ]);
          merge =
            loc: defs:
            let
              pushPositions = map (
                def:
                builtins.mapAttrs (_n: v: {
                  inherit (def) file;
                  value = v;
                }) def.value.value
              );
            in
            {
              __type = "namedStruct";
              name =
                if builtins.length defs == 0 then
                  abort "This case should not happen."
                else if builtins.length defs == 1 then
                  (builtins.head defs).value.name
                else
                  builtins.foldl' (
                    first: def:
                    if def.value.name != first.value.name then
                      throw "The option '${lib.showOption loc}' has conflicting definition values: ${
                        lib.options.showDefs [
                          first
                          def
                        ]
                      }"
                    else
                      first.value.name
                  ) (builtins.head defs) (builtins.tail defs);
              value = builtins.mapAttrs (_n: v: v.value) (
                lib.filterAttrs (_n: v: v ? value) (
                  builtins.zipAttrsWith (
                    name: defs: (lib.mergeDefinitions (loc ++ [ name ]) elemType defs).optionalValue
                  ) (pushPositions defs)
                )
              );
            };
          inherit name;
          nestedTypes.elemType = elemType;
          substSubModules = m: ronNamedStructOf' (elemType.substSubModules m);
        };
    in
    ronNamedStructOf';

  ronOptional = lib.mkOptionType {
    check =
      value:
      let
        keys = builtins.attrNames value;
      in
      builtins.isAttrs value
      &&
        [
          "__type"
          "value"
        ] == keys
      && value.__type == "optional"
      && !builtins.isFunction value.value
      && !builtins.isPath value.value;
    description = "RON optional";
    descriptionClass = "noun";
    merge = lib.options.mergeEqualOption;
    name = "ronOptional";
  };

  ronOptionalOf =
    let
      ronOptionalOf' =
        let
          name = "ronOptionalOf";
        in
        elemType:
        lib.mkOptionType {
          check =
            value:
            let
              keys = builtins.attrNames value;
            in
            builtins.isAttrs value
            &&
              [
                "__type"
                "value"
              ] == keys
            && value.__type == "optional"
            && !builtins.isFunction value.value
            && !builtins.isPath value.value;
          description = "RON optional of ${
            lib.types.optionDescriptionPhrase (class: class == "noun" || class == "composite") elemType
          }";
          descriptionClass = "composite";
          functor = lib.defaultFunctor name // {
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
              lib.warn ''
                The deprecated `type.functor.wrapped` attribute of the option `${lib.showOption loc}` is accessed, use `type.nestedTypes.elemType` instead.
              '' elemType;
          };
          inherit (elemType) getSubModules getSubOptions;
          merge = loc: defs: {
            __type = "optional";
            value =
              (lib.mergeDefinitions loc (lib.types.nullOr elemType) (
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
        assert lib.assertMsg (size > 0) "The size must be greater than zero.";
        lib.mkOptionType {
          check =
            value:
            let
              keys = builtins.attrNames value;
            in
            builtins.isAttrs value
            &&
              [
                "__type"
                "value"
              ] == keys
            && value.__type == "tuple"
            && builtins.isList value.value
            && builtins.length value.value == size;
          description = "RON tuple";
          descriptionClass = "noun";
          emptyValue = {
            value = {
              __type = "tuple";
              value = [ ];
            };
          };
          functor = lib.defaultFunctor name // {
            payload = { inherit size; };
            type = payload: ronTuple' payload.size;
            binOp = a: b: {
              size = if a.size == b.size then a.size else throw "The tuple sizes do not match.";
            };
          };
          merge = _loc: defs: {
            __type = "tuple";
            value = builtins.concatLists (map (x: x.value.value) defs);
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
        assert lib.assertMsg (builtins.all (
          value: builtins.isString value
        ) variants) "All variants in the enum must be strings.";
        assert lib.assertMsg (size > 0) "The size must be greater than zero.";
        lib.mkOptionType {
          check =
            value:
            let
              keys = builtins.attrNames value;
            in
            builtins.isAttrs value
            &&
              [
                "__type"
                "value"
                "variant"
              ] == keys
            && value.__type == "enum"
            && builtins.elem value.variant variants
            && builtins.isList value.value
            && builtins.length value.value == size;
          description =
            if variants == [ ] then
              "impossible (empty RON tuple enum)"
            else if builtins.length variants == 1 then
              "RON enum variant ${show (builtins.head variants)} with ${toString size} ${
                if size == 1 then "value (singular RON tuple enum)" else "values (singular RON tuple enum)"
              }"
            else
              "one of the following RON tuple enum variants: ${
                lib.concatMapStringsSep ", " show variants
              } with a value";
          descriptionClass = if builtins.length variants < 2 then "noun" else "conjunction";
          functor = lib.defaultFunctor name // {
            payload = { inherit size variants; };
            type = payload: ronTupleEnum' payload.variants payload.size;
            binOp = a: b: {
              variants = lib.unique (a.variants + b.variants);
              size = if a.size == b.size then a.size else throw "The tuple sizes do not match.";
            };
          };
          merge = lib.options.mergeEqualOption;
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
        assert lib.assertMsg (builtins.all (
          value: builtins.isString value
        ) variants) "All variants in the enum must be strings.";
        assert lib.assertMsg (size > 0) "The size must be greater than zero.";
        lib.mkOptionType {
          check =
            value:
            let
              keys = builtins.attrNames value;
            in
            builtins.isAttrs value
            &&
              [
                "__type"
                "value"
                "variant"
              ] == keys
            && value.__type == "enum"
            && builtins.elem value.variant variants
            && builtins.isList value.value
            && builtins.length value.value == size;
          description =
            if variants == [ ] then
              "impossible (empty RON tuple enum)"
            else if builtins.length variants == 1 then
              "RON enum variant ${show (builtins.head variants)} with ${toString size} ${
                lib.types.optionDescriptionPhrase (class: class == "noun" || class == "composite") elemType
              } ${if size == 1 then "value (singular RON tuple enum)" else "values (singular RON tuple enum)"}"
            else
              "one of the following RON tuple enum variants: ${
                lib.concatMapStringsSep ", " show variants
              } with ${toString size} ${
                lib.types.optionDescriptionPhrase (class: class == "noun" || class == "composite") elemType
              } ${if size == 1 then "value" else "values"}";
          descriptionClass = if builtins.length variants < 2 then "noun" else "conjunction";
          functor = lib.defaultFunctor name // {
            payload = { inherit elemType size variants; };
            type = payload: ronTupleEnumOf' payload.elemType payload.variants payload.size;
            binOp = a: b: {
              variants = lib.unique (a.variants + b.variants);
              elemType = a.elemType.typeMerge b.elemType.functor;
              size = if a.size == b.size then a.size else throw "The tuple sizes do not match.";
            };
          };
          inherit (elemType) getSubModules;
          getSubOptions = prefix: elemType.getSubOptions (prefix ++ [ "*" ]);
          merge = loc: defs: {
            __type = "enum";
            value = map (x: x.value) (
              builtins.filter (x: x ? value) (
                builtins.concatLists (
                  lib.imap1 (
                    n: def:
                    lib.imap1 (
                      m: def':
                      (lib.mergeDefinitions (loc ++ [ "[definition ${toString n}-entry ${toString m}]" ]) elemType [
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
              if builtins.length defs == 0 then
                abort "This case should not happen."
              else if builtins.length defs == 1 then
                (builtins.head defs).value.variant
              else
                builtins.foldl' (
                  first: def:
                  if def.value.variant != first.value.variant then
                    throw "The option '${lib.showOption (loc ++ [ "variant" ])}' has conflicting definition values: ${
                      lib.options.showDefs [
                        first
                        def
                      ]
                    }"
                  else
                    first.value.variant
                ) (builtins.head defs) (builtins.tail defs);
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
        assert lib.assertMsg (size > 0) "The size must be greater than zero.";
        lib.mkOptionType {
          check =
            value:
            let
              keys = builtins.attrNames value;
            in
            builtins.isAttrs value
            &&
              [
                "__type"
                "value"
              ] == keys
            && value.__type == "tuple"
            && builtins.isList value.value
            && builtins.length value.value == size;
          description = "RON tuple of ${
            lib.types.optionDescriptionPhrase (class: class == "noun" || class == "composite") elemType
          } with a fixed-size of ${toString size} elements";
          descriptionClass = "composite";
          emptyValue = {
            value = {
              __type = "tuple";
              value = [ ];
            };
          };
          functor = lib.defaultFunctor name // {
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
              lib.warn ''
                The deprecated `type.functor.wrapped` attribute of the option `${lib.showOption loc}` is accessed, use `type.nestedTypes.elemType` instead.
              '' elemType;
          };
          inherit (elemType) getSubModules;
          getSubOptions = prefix: elemType.getSubOptions (prefix ++ [ "*" ]);
          merge = loc: defs: {
            __type = "tuple";
            value = map (x: x.value) (
              builtins.filter (x: x ? value) (
                builtins.concatLists (
                  lib.imap1 (
                    n: def:
                    lib.imap1 (
                      m: def':
                      (lib.mergeDefinitions (loc ++ [ "[definition ${toString n}-entry ${toString m}]" ]) elemType [
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
}
