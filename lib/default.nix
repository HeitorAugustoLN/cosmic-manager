{ lib, ... }:
{
  generators = import ./generators.nix { inherit lib; };
}
