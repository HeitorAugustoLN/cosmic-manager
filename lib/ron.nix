{ lib, ... }:
let
  inherit (builtins)
    all
    attrNames
    fromJSON
    head
    isAttrs
    isList
    isString
    length
    listToAttrs
    match
    readFile
    substring
    stringLength
    typeOf
    ;
  inherit (lib)
    boolToString
    concatImapStringsSep
    foldl
    hasInfix
    last
    optionalString
    pipe
    splitString
    stringToCharacters
    toInt
    trim
    ;
  inherit (lib.cosmic) mkAssertion mkThrow mkWarning;
  inherit (lib.strings) escapeNixString floatToString replicate;

  fromRON =
    let
      fromRON' =
        str:
        let
          trimmed = trim str;

          firstChar = substring 0 1 trimmed;
          lastChar = substring (stringLength trimmed - 1) 1 trimmed;

          splitItems =
            str:
            let
              content = pipe str [
                trim
                (substring 1 (stringLength str - 2))
                trim
              ];

              split =
                acc: current: depth: rest:
                if rest == "" then
                  if current != "" then acc ++ [ (trim current) ] else acc
                else
                  let
                    char = substring 0 1 rest;
                    remaining = substring 1 (-1) rest;
                  in
                  if char == "(" || char == "[" || char == "{" then
                    split acc (current + char) (depth + 1) remaining
                  else if char == ")" || char == "]" || char == "}" then
                    split acc (current + char) (depth - 1) remaining
                  else if char == "," && depth == 0 then
                    split (acc ++ [ (trim current) ]) "" depth remaining
                  else
                    split acc (current + char) depth remaining;
            in
            split [ ] "" 0 content;

          findFirstColon =
            str:
            let
              helper =
                pos: depth:
                if pos >= stringLength str then
                  null
                else
                  let
                    char = substring pos 1 str;
                  in
                  if char == "(" || char == "[" || char == "{" then
                    helper (pos + 1) (depth + 1)
                  else if char == ")" || char == "]" || char == "}" then
                    helper (pos + 1) (depth - 1)
                  else if char == ":" && depth == 0 then
                    pos
                  else
                    helper (pos + 1) depth;
            in
            helper 0 0;

          isStruct =
            str:
            let
              content = pipe str [
                trim
                (substring 1 (stringLength str - 2))
                trim
              ];
              colonPos = findFirstColon content;

              beforeColon = substring 0 colonPos content;
              depth = foldl (
                acc: char:
                if char == "(" || char == "[" || char == "{" then
                  acc + 1
                else if char == ")" || char == "]" || char == "}" then
                  acc - 1
                else
                  acc
              ) 0 (stringToCharacters beforeColon);
            in
            colonPos != null && depth == 0;
        in
        if firstChar == "[" && lastChar == "]" then
          map fromRON' (splitItems trimmed)
        else if firstChar == "{" && lastChar == "}" then
          {
            __type = "map";
            value = map (
              item:
              let
                colonPos = findFirstColon item;
                key = trim (substring 0 colonPos item);
                value = trim (substring (colonPos + 1) (-1) item);
              in
              {
                key = fromRON' key;
                value = fromRON' value;
              }
            ) (splitItems trimmed);
          }
        else if trimmed == "None" then
          {
            __type = "optional";
            value = null;
          }
        else if match "Some\\(.*\\)" trimmed != null then
          let
            value = head (match "Some\\((.*)\\)" trimmed);
          in
          {
            __type = "optional";
            value = fromRON' value;
          }
        else if trimmed == "true" then
          true
        else if trimmed == "false" then
          false
        else if firstChar == "(" && lastChar == ")" then
          if isStruct trimmed then
            listToAttrs (
              map (
                item:
                let
                  colonPos = findFirstColon item;
                  name = trim (substring 0 colonPos item);
                  value = trim (substring (colonPos + 1) (-1) item);
                in
                {
                  inherit name;
                  value = fromRON' value;
                }
              ) (splitItems trimmed)
            )
          else
            {
              __type = "tuple";
              value = map fromRON' (splitItems trimmed);
            }
        else if match "[A-Za-z_][A-Za-z0-9_]*\\(.*\\)" trimmed != null then
          let
            matches = match "([A-Za-z_][A-Za-z0-9_]*)(\\(.*\\))" trimmed;
            name = trim (head matches);
            value = trim (last matches);
          in
          if isStruct value then
            {
              __type = "namedStruct";
              inherit name;
              value = fromRON' value;
            }
          else
            {
              __type = "enum";
              variant = name;
              value = map fromRON' (splitItems value);
            }
        else if match "-?[0-9]+[.][0-9]+" trimmed != null then
          let
            decimals = pipe trimmed [
              (splitString ".")
              last
              stringLength
            ];
          in
          if decimals > 5 then
            {
              __type = "raw";
              value = trimmed;
            }
          else
            fromJSON trimmed
        else if match "-?[0-9]+" trimmed != null then
          toInt trimmed
        else if match "'.'" trimmed != null then
          {
            __type = "char";
            value = substring 1 1 trimmed;
          }
        else if match ''".*"'' trimmed != null then
          fromJSON trimmed
        else
          {
            __type = "raw";
            value = trimmed;
          };
    in
    mkWarning "fromRON"
      "This function is experimental, from my testing it works well, but it may not work in all cases. Please report any issues you find."
      fromRON';
in
{
  inherit fromRON;

  importRON =
    path:
    pipe path [
      readFile
      fromRON
    ];

  isRONType =
    v:
    v ? __type
    && (
      (
        (
          v.__type == "char"
          || v.__type == "map"
          || v.__type == "optional"
          || v.__type == "raw"
          || v.__type == "tuple"
        )
        && v ? value
      )
      || (v.__type == "namedStruct" && v ? name && v ? value)
      || (v.__type == "enum" && (v ? variant || (v ? variant && v ? value)))
    );

  mkRON =
    type: value:
    {
      char = {
        __type = "char";
        inherit value;
      };

      enum =
        if isAttrs value then
          assert mkAssertion "mkRON" (
            attrNames value == [
              "value"
              "variant"
            ]
          ) "enum type must receive a string or an attribute set with value and variant keys value";
          {
            __type = "enum";
            inherit (value) value variant;
          }
        else
          {
            __type = "enum";
            variant = value;
          };

      map = {
        __type = "map";
        inherit value;
      };

      namedStruct =
        assert mkAssertion "mkRON" (
          isAttrs value
          &&
            attrNames value == [
              "name"
              "value"
            ]
        ) "namedStruct type must receive an attribute set with name and value keys.";
        {
          __type = "namedStruct";
          inherit (value) name value;
        };

      optional = {
        __type = "optional";
        inherit value;
      };

      raw = {
        __type = "raw";
        inherit value;
      };

      tuple = {
        __type = "tuple";
        inherit value;
      };
    }
    .${type} or (mkThrow "mkRON" "${type} is not supported.");

  toRON =
    let
      toRON' =
        startIndent: value:
        let
          type = typeOf value;
          nextIndent = startIndent + 1;

          indent = level: replicate level "    ";
        in
        {
          bool = boolToString value;
          float =
            let
              trimFloatString =
                float:
                let
                  string = floatToString float;
                in
                if hasInfix "." string then head (match "([0-9]+[.][0-9]*[1-9]|[0-9]+[.]0)0*" string) else string;
            in
            trimFloatString value;
          int = toString value;
          lambda = mkThrow "toRON" "Functions are not supported in RON";
          list =
            let
              count = length value;
            in
            if count == 0 then
              "[]"
            else
              "[\n${
                concatImapStringsSep "\n" (
                  index: element:
                  "${indent nextIndent}${toRON' nextIndent element}${optionalString (index != count) ","}"
                ) value
              },\n${indent startIndent}]";
          null = mkThrow "toRON" ''
            Null values are cleaned up by lib.cosmic.utils.cleanNullsExceptOptional.
            If you are seeing this message, please report this, as it should not happen.

            If you want to represent a null value in RON, you can use the `optional` type.
          '';
          path = mkThrow "toRON" "Path is not supported in RON";
          set =
            if value ? __type then
              if value.__type == "raw" then
                assert mkAssertion "toRON" (value ? value) "raw type must have a value.";
                assert mkAssertion "toRON" (isString value.value) "raw type value must be a string.";

                value.value
              else if value.__type == "optional" then
                assert mkAssertion "toRON" (value ? value) "optional type must have a value.";

                if value.value == null then "None" else "Some(${toRON' startIndent value.value})"
              else if value.__type == "char" then
                assert mkAssertion "toRON" (value ? value) "char type must have a value.";
                assert mkAssertion "toRON" (isString value.value) "char type value must be a string.";
                assert mkAssertion "toRON" (
                  stringLength value.value == 1
                ) "char type value must be a single character string.";

                "'${value.value}'"
              else if value.__type == "enum" then
                assert mkAssertion "toRON" (value ? variant) "enum type must have a variant.";
                assert mkAssertion "toRON" (isString value.variant) "enum type variant must be a string value.";

                if value ? value then
                  assert mkAssertion "toRON" (isList value.value) "enum type must have a list of values.";

                  let
                    count = length value.value;
                  in
                  if count == 0 then
                    "${value.variant}()"
                  else
                    "${value.variant}(\n${
                      concatImapStringsSep "\n" (
                        index: element:
                        "${indent nextIndent}${toRON' nextIndent element}${optionalString (index != count) ","}"
                      ) value.value
                    },\n${indent startIndent})"
                else
                  value.variant
              else if value.__type == "map" then
                assert mkAssertion "toRON" (value ? value) "map type must have a value.";
                assert mkAssertion "toRON" (isList value.value) "map type value must be a list.";
                assert mkAssertion "toRON" (all isAttrs value.value)
                  "map type value must be a list of attribute sets.";

                let
                  count = length value.value;
                in
                if count == 0 then
                  "{}"
                else
                  "{\n${
                    concatImapStringsSep "\n" (
                      index: entry:
                      assert mkAssertion "toRON" (
                        let
                          keys = attrNames entry;
                        in
                        keys == [
                          "key"
                          "value"
                        ]
                      ) "map type entry must have only 'key' and 'value' attributes.";

                      "${indent nextIndent}${toRON' nextIndent entry.key}: ${toRON' nextIndent entry.value}${
                        optionalString (index != count) ","
                      }"
                    ) value.value
                  },\n${indent startIndent}}"
              else if value.__type == "tuple" then
                assert mkAssertion "toRON" (value ? value) "tuple type must have a value.";
                assert mkAssertion "toRON" (isList value.value) "tuple type value must be a list.";

                let
                  count = length value.value;
                in
                if count == 0 then
                  "()"
                else
                  "(\n${
                    concatImapStringsSep "\n" (
                      index: element:
                      "${indent nextIndent}${toRON' nextIndent element}${optionalString (index != count) ","}"
                    ) value.value
                  },\n${indent startIndent})"
              else if value.__type == "namedStruct" then
                assert mkAssertion "toRON" (value ? name) "namedStruct type must have a name.";
                assert mkAssertion "toRON" (isString value.name) "namedStruct type name must be a string.";
                assert mkAssertion "toRON" (value ? value) "namedStruct type must have a value.";
                assert mkAssertion "toRON" (isAttrs value.value) "namedStruct type value must be a attribute set.";

                let
                  keys = attrNames value.value;
                  count = length keys;
                in
                if count == 0 then
                  "${value.name}()"
                else
                  "${value.name}(\n${
                    concatImapStringsSep "\n" (
                      index: key:
                      "${indent nextIndent}${key}: ${toRON' nextIndent value.value.${key}}${
                        optionalString (index != count) ","
                      }"
                    ) keys
                  },\n${indent startIndent})"
              else
                mkThrow "toRON" "set type ${toString value.__type} is not supported."
            else
              let
                keys = attrNames value;
                count = length keys;
              in
              if count == 0 then
                "()"
              else
                "(\n${
                  concatImapStringsSep "\n" (
                    index: key:
                    "${indent nextIndent}${key}: ${toRON' nextIndent value.${key}}${
                      optionalString (index != count) ","
                    }"
                  ) keys
                },\n${indent startIndent})";
          string = escapeNixString value;
        }
        .${type} or (mkThrow "toRON" "${type} is not supported.");
    in
    toRON';
}
