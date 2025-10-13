{
  description = "Manage COSMIC desktop declaratively using home-manager";

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./flake);

  inputs = {
    flake-parts = {
      type = "github";
      owner = "hercules-ci";
      repo = "flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    home-manager = {
      type = "github";
      # owner = "nix-community";
      owner = "HeitorAugustoLN";
      repo = "home-manager";
      ref = "cosmic-upstreaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    import-tree = {
      type = "github";
      owner = "vic";
      repo = "import-tree";
    };

    nixpkgs = {
      type = "github";
      owner = "HeitorAugustoLN";
      repo = "nixpkgs";
      ref = "patched";
    };

    systems = {
      type = "github";
      owner = "nix-systems";
      repo = "default-linux";
    };
  };
}
