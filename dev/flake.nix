{
  inputs = {
    cosmic-manager = {
      type = "path";
      path = "../.";
    };

    flake-compat = {
      type = "github";
      owner = "edolstra";
      repo = "flake-compat";
    };

    git-hooks = {
      type = "github";
      owner = "cachix";
      repo = "git-hooks.nix";

      inputs = {
        flake-compat.follows = "flake-compat";
        nixpkgs.follows = "nixpkgs";
      };
    };

    nixpkgs.follows = "cosmic-manager/nixpkgs";

    treefmt-nix = {
      type = "github";
      owner = "numtide";
      repo = "treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = _: { };
}
