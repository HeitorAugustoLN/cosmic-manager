{
  config,
  lib,
  pkgs,
  ...
}:
lib.extend (
  final: prev: {
    cosmic = import ./. {
      inherit config pkgs;
      lib = final;
    };

    types = prev.types // import ./types.nix { lib = final; };
  }
)
