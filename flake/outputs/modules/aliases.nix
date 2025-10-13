{ inputs, self, ... }:
{
  imports = [
    inputs.flake-parts.flakeModules.modules
    inputs.home-manager.flakeModules.default
  ];

  flake = {
    homeModules = { inherit (self.modules.homeManager) cosmic-manager default; };
    nixosModules = { inherit (self.modules.nixos) cosmic-manager default; };

    modules = {
      homeManager.default = self.modules.homeManager.cosmic-manager;
      nixos.default = self.modules.nixos.cosmic-manager;
    };
  };
}
