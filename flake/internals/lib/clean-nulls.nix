{ lib, ... }:
{
  _module.args.cosmicLib.cleanNullsExceptOptional =
    let
      cleanNullsExceptOptional' =
        attrset:
        lib.filterAttrs (_: value: value != null) (
          builtins.mapAttrs (
            _: value:
            if builtins.isAttrs value && !(lib.isType "ron-optional" && value.value == null) then
              cleanNullsExceptOptional' value
            else
              value
          ) attrset
        );
    in
    cleanNullsExceptOptional';
}
