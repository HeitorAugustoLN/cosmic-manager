{ lib, pkgs }:
let
  args = pkgs // {
    lib = import ../lib/extend-lib.nix { inherit lib; };

    inherit callTest;
  };

  callTest = lib.callPackageWith args;
in
{
  from-ron = callTest ./from-ron.nix { };
  shortcuts = callTest ./shortcuts.nix { };
  to-ron = callTest ./to-ron.nix { };
}
