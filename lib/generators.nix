{ lib, ... }:
{
  toRON =
    let
      toRON' =
        startIndent: value:
        let
          type = builtins.typeOf value;
          nextIndent = startIndent + 1;

          indent = level: lib.strings.replicate level "    ";
          trimFloatString =
            float:
            let
              string = lib.strings.floatToString float;
            in
            if lib.strings.hasInfix "." string then
              builtins.head (builtins.match "([0-9]+[.][0-9]*[1-9]|[0-9]+[.]0)0*" string)
            else
              string;
        in
        {
          bool = lib.boolToString value;
          float = trimFloatString value;
          int = toString value;
          lambda = throw "Functions are not supported in RON";
          list =
            let
              count = builtins.length value;
            in
            if count == 0 then
              "[]"
            else
              "[\n${
                lib.concatImapStringsSep "\n" (
                  index: element:
                  "${indent nextIndent}${toRON' nextIndent element}${lib.optionalString (index != count) ","}"
                ) value
              },\n${indent startIndent}]";
          null = throw ''
            Null values are cleaned up by lib.cosmic.utils.cleanNullsExceptOptional.
            If you are seeing this message, please report this, as it should not happen.

            If you want to represent a null value in RON, you can use the `option` type.
          '';
          path = throw "Path is not supported in RON";
          set =
            if value ? __type then
              if value.__type == "raw" then
                toString value.value
              else if value.__type == "option" then
                if value.value == null then "None" else "Some(${toRON' startIndent value.value})"
              else if value.__type == "char" then
                if builtins.stringLength value.value == 1 then
                  "'${value.value}'"
                else
                  throw "lib.cosmic.generators.toRON: char type must be a single character."
              else if value.__type == "map" then
                let
                  keys = builtins.attrNames value.value;
                  count = builtins.length keys;

                  isNumeric = string: builtins.match "^[0-9]+$" string != null;
                in
                if count == 0 then
                  "{}"
                else
                  "{\n${
                    lib.concatImapStringsSep "\n" (
                      index: key:
                      "${indent nextIndent}${
                        if isNumeric key then key else lib.strings.escapeNixString key
                      }: ${toRON' nextIndent (builtins.getAttr key value.value)}${
                        lib.optionalString (index != count) ","
                      }"
                    ) keys
                  },\n${indent startIndent}}"
              else if value.__type == "tuple" then
                let
                  count = builtins.length value.value;
                in
                if count == 0 then
                  "()"
                else
                  "(\n${
                    lib.concatImapStringsSep "\n" (
                      index: element:
                      "${indent nextIndent}${toRON' nextIndent element}${lib.optionalString (index != count) ","}"
                    ) value.value
                  },\n${indent startIndent})"
              else
                throw "lib.cosmic.generators.toRON: set type ${value.__type} is not supported."
            else
              let
                keys = builtins.attrNames (if value ? __name then value.value else value);
                count = builtins.length keys;
              in
              if count == 0 then
                "()"
              else
                "${lib.optionalString (value ? __name) value.__name}(\n${
                  lib.concatImapStringsSep "\n" (
                    index: key:
                    "${indent nextIndent}${key}: ${
                      toRON' nextIndent (builtins.getAttr key (if value ? __name then value.value else value))
                    }${lib.optionalString (index != count) ","}"
                  ) keys
                },\n${indent startIndent})";
          string = lib.strings.escapeNixString value;
        }
        .${type} or (throw "lib.cosmic.generators.toRON: ${type} is not supported.");
    in
    toRON';
}
