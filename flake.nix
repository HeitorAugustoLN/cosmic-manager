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

          devShells.default = import ./shell.nix {
            inherit pkgs;
            inherit (self'.packages) cosmic-manager;
          };

          formatter = pkgs.treefmt;

          packages = {
            default = self'.packages.cosmic-manager;

            cosmic-manager = pkgs.callPackage ./cosmic-manager { };

            home-manager-options = mkOptionsDoc {
              inherit version;
              moduleRoot = ./modules;
            };

            gen-local-options = pkgs.writeShellApplication {
              name = "gen-local-options";
              text = ''
                root="$(git rev-parse --show-toplevel)"
                cp ${self'.packages.home-manager-options} "$root/docs/src/options/README.md"
              '';
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
