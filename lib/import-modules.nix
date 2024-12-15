{
  modules,
  config,
  lib,
  pkgs,
  ...
}:
let
  toModule = file: {
    _file = file;
    imports = [
      (import file {
        inherit config pkgs;
        lib = import ./extend-lib.nix { inherit config lib pkgs; };
      })
    ];
  };
in
map toModule modules
