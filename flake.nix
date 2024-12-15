{
  description = "Manage COSMIC Desktop using home-manager";

  inputs = {
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cosmic-ctl = {
      url = "github:cosmic-utils/cosmic-ctl";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];

      flake = {
        homeManagerModules = {
          default = inputs.self.homeManagerModules.cosmic-manager;
          cosmic-manager = import ./modules inputs;
        };
      };

      perSystem =
        { pkgs, ... }:
        {
          devShells.default = import ./shell.nix { inherit pkgs; };

          formatter = pkgs.treefmt;
        };
    };
}
