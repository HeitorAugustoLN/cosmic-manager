{ lib, ... }:
{
  applets = import ./applets.nix { inherit lib; };
  applications = import ./applications.nix { inherit lib; };
  generators = import ./generators.nix { inherit lib; };
  modules = import ./modules.nix { inherit lib; };
  options = import ./options.nix { inherit lib; };
  utils = import ./utils.nix { inherit lib; };
}
