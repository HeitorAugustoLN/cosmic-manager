{ lib, ... }:
{
  cleanNullsExceptOptional =
    let
      cleanNullsExceptOptional' =
        attrset:
        lib.filterAttrs (_name: value: value != null) (
          builtins.mapAttrs (
            _name: value:
            if
              builtins.isAttrs value && !(value ? __type && value.__type == "optional" && value.value == null)
            then
              cleanNullsExceptOptional' value
            else
              value
          ) attrset
        );
    in
    cleanNullsExceptOptional';

  capitalizeWord =
    word:
    with lib.strings;
    concatImapStrings (index: char: if index == 1 then toUpper char else toLower char) (
      stringToCharacters word
    );
}
