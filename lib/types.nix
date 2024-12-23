{ lib, ... }:
{
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
        type = with lib.types; attrsOf cosmicEntryValue;
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

  cosmicEntryValue =
    with lib.types;
    nullOr (oneOf [
      (attrsOf anything)
      bool
      (listOf anything)
      number
      rawRon
      ronChar
      (ronMapOf anything)
      (ronNamedStructOf anything)
      (ronOptionalOf anything)
      (ronTupleOf anything)
      str
    ]);

  hexColor = lib.types.strMatching "^#?([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$" // {
    description = "hex color";
  };

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
        if !builtins.all (value: builtins.isString value) variants then
          throw "All values in the enum must be strings."
        else
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
      && builtins.isAttrs value.value;
    description = "RON map";
    descriptionClass = "noun";
    emptyValue = {
      value = {
        __type = "map";
        value = { };
      };
    };
    merge = loc: defs: {
      __type = "map";
      value = builtins.foldl' (first: def: lib.recursiveUpdate first def.value.value) { } defs;
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
            && builtins.isAttrs value.value;
          description = "RON map of ${
            lib.types.optionDescriptionPhrase (class: class == "noun" || class == "composite") elemType
          }";
          descriptionClass = "composite";
          emptyValue = {
            value = {
              __type = "map";
              value = { };
            };
          };
          functor = lib.defaultFunctor name // {
            wrapped = elemType;
          };
          getSubModules = elemType.getSubModules;
          getSubOptions = prefix: elemType.getSubOptions (prefix ++ [ "<name>" ]);
          merge =
            loc: defs:
            let
              pushPositions = map (
                def:
                builtins.mapAttrs (n: v: {
                  inherit (def) file;
                  value = v;
                }) def.value.value
              );
            in
            {
              __type = "map";
              value = builtins.mapAttrs (n: v: v.value) (
                lib.filterAttrs (n: v: v ? value) (
                  lib.zipAttrsWith (
                    name: defs: (lib.mergeDefinitions (loc ++ [ name ]) elemType defs).optionalValue
                  ) (pushPositions defs)
                )
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
          "__name"
          "value"
        ] == keys
      && builtins.isString value.__name
      && builtins.isAttrs value.value;
    description = "RON named struct";
    descriptionClass = "noun";
    merge = loc: defs: {
      __name =
        if builtins.length defs == 0 then
          abort "This case should not happen."
        else if builtins.length defs == 1 then
          (builtins.head defs).value.__name
        else
          builtins.foldl' (
            first: def:
            if def.value.__name != first.value.__name then
              throw "The option '${lib.showOption loc}' has conflicting definition values: ${
                lib.options.showDefs [
                  first
                  def
                ]
              }\nUse `lib.mkForce value` or `lib.mkDefault value` to change the priority on any of these definitions."
            else
              first.value.__name
          ) (builtins.head defs) (builtins.tail defs);
      value = builtins.foldl' (first: def: lib.recursiveUpdate first def.value.value) { } defs;
    };
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
                "__name"
                "value"
              ] == keys
            && builtins.isString value.__name
            && builtins.isAttrs value.value;
          description = "RON named struct of ${
            lib.types.optionDescriptionPhrase (class: class == "noun" || class == "composite") elemType
          }";
          descriptionClass = "composite";
          functor = lib.defaultFunctor name // {
            wrapped = elemType;
          };
          getSubModules = elemType.getSubModules;
          getSubOptions = prefix: elemType.getSubOptions (prefix ++ [ "<name>" ]);
          merge =
            loc: defs:
            let
              pushPositions = map (
                def:
                builtins.mapAttrs (n: v: {
                  inherit (def) file;
                  value = v;
                }) def.value.value
              );
            in
            {
              __name =
                if builtins.length defs == 0 then
                  abort "This case should not happen."
                else if builtins.length defs == 1 then
                  (builtins.head defs).value.__name
                else
                  builtins.foldl' (
                    first: def:
                    if def.value.__name != first.value.__name then
                      throw "The option '${lib.showOption loc}' has conflicting definition values: ${
                        lib.options.showDefs [
                          first
                          def
                        ]
                      }\nUse `lib.mkForce value` or `lib.mkDefault value` to change the priority on any of these definitions."
                    else
                      first.value.__name
                  ) (builtins.head defs) (builtins.tail defs);
              value = builtins.mapAttrs (n: v: v.value) (
                lib.filterAttrs (n: v: v ? value) (
                  lib.zipAttrsWith (
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
            wrapped = elemType;
          };
          getSubModules = elemType.getSubModules;
          getSubOptions = prefix: elemType.getSubOptions (prefix ++ [ "<name>" ]);
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

  ronTuple = lib.mkOptionType {
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
      && builtins.isList value.value;
    description = "RON tuple";
    descriptionClass = "noun";
    emptyValue = {
      value = {
        __type = "tuple";
        value = [ ];
      };
    };
    merge = loc: defs: {
      __type = "tuple";
      value = builtins.concatLists (map (x: x.value.value) defs);
    };
    name = "ronTuple";
  };

  ronTupleEnum =
    let
      ronTupleEnum' =
        let
          name = "ronTupleEnum";
          show = v: ''"${v}"'';
        in
        variants:
        if !builtins.all (value: builtins.isString value) variants then
          throw "All variants in the enum must be strings."
        else
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
              && builtins.isList value.value;
            description =
              if variants == [ ] then
                "impossible (empty RON tuple enum)"
              else if builtins.length variants == 1 then
                "RON enum variant ${show (builtins.head variants)} with a value (singular RON tuple enum)"
              else
                "one of the following RON tuple enum variants: ${
                  lib.concatMapStringsSep ", " show variants
                } with a value";
            descriptionClass = if builtins.length variants < 2 then "noun" else "conjunction";
            functor = lib.defaultFunctor name // {
              payload = { inherit variants; };
              type = payload: ronTupleEnum' payload.variants;
              binOp = a: b: { variants = lib.unique (a.variants + b.variants); };
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
        elemType: variants:
        if !builtins.all (value: builtins.isString value) variants then
          throw "All variants in the enum must be strings."
        else
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
              && builtins.isList value.value;
            description =
              if variants == [ ] then
                "impossible (empty RON tuple enum)"
              else if builtins.length variants == 1 then
                "RON enum variant ${show (builtins.head variants)} with a ${
                  lib.types.optionDescriptionPhrase (class: class == "noun" || class == "composite") elemType
                } value (singular RON tuple enum)"
              else
                "one of the following RON tuple enum variants: ${
                  lib.concatMapStringsSep ", " show variants
                } with a ${
                  lib.types.optionDescriptionPhrase (class: class == "noun" || class == "composite") elemType
                } value";
            descriptionClass = if builtins.length variants < 2 then "noun" else "conjunction";
            functor = lib.defaultFunctor name // {
              payload = { inherit elemType variants; };
              type = payload: ronTupleEnumOf' payload.elemType payload.variants;
              binOp = a: b: {
                variants = lib.unique (a.variants + b.variants);
                elemType = a.elemType.typeMerge b.elemType.functor;
              };
            };
            getSubModules = elemType.getSubModules;
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
                      }\nUse `lib.mkForce value` or `lib.mkDefault value` to change the priority on any of these definitions."
                    else
                      first.value.variant
                  ) (builtins.head defs) (builtins.tail defs);
            };
            inherit name;
            nestedTypes.elemType = elemType;
            substSubModules = m: ronTupleEnumOf' (elemType.substSubModules m) variants;
          };
    in
    ronTupleEnumOf';

  ronTupleOf =
    let
      ronTupleOf' =
        let
          name = "ronTupleOf";
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
            && value.__type == "tuple"
            && builtins.isList value.value;
          description = "RON tuple of ${
            lib.types.optionDescriptionPhrase (class: class == "noun" || class == "composite") elemType
          }";
          descriptionClass = "composite";
          emptyValue = {
            value = {
              __type = "tuple";
              value = [ ];
            };
          };
          functor = lib.defaultFunctor name // {
            wrapped = elemType;
          };
          getSubModules = elemType.getSubModules;
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
          substSubModules = m: ronTupleOf' (elemType.substSubModules m);
        };
    in
    ronTupleOf';
}
