{
  description = "Manage COSMIC desktop declaratively using home-manager";

  inputs = {
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
      ];

      flake.homeManagerModules = {
        default = inputs.self.homeManagerModules.cosmic-manager;
        cosmic-manager = ./modules;
      };

      perSystem =
        { pkgs, self', ... }:
        let
          version = inputs.self.shortRev or inputs.self.dirtyShortRev or "unknown";

          mkOptionsDoc = pkgs.callPackage ./docs/options.nix { };
          mkSite = pkgs.callPackage ./docs/generate-website.nix { };
        in
        {
          checks = pkgs.callPackages ./tests { };

          devShells.default = import ./shell.nix { inherit pkgs; };

          formatter = pkgs.treefmt;

          packages = {
            default = self'.packages.site;

            home-manager-options = mkOptionsDoc {
              inherit version;
              moduleRoot = ./modules;
            };

            site =
              let
                src =
                  let
                    inherit (pkgs) lib;
                  in
                  lib.fileset.toSource {
                    root = ./.;
                    fileset = lib.fileset.unions [
                      ./docs/book.toml
                      ./docs/src
                    ];
                  };
              in
              mkSite {
                pname = "cosmic-manager-website";
                inherit version src;

                sourceRoot = "${src.name}/docs";
                options = self'.packages.home-manager-options;
              };
          };
        };
    };
}
