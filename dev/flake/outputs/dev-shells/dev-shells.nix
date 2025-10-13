{
  perSystem =
    {
      config,
      pkgs,
      ...
    }:
    {
      devShells.default = pkgs.mkShell {
        packages = [
          pkgs.cargo
          pkgs.clippy
          pkgs.rustc
        ]
        ++ config.pre-commit.settings.enabledPackages
        ++ (builtins.attrValues config.treefmt.build.programs);

        shellHook = config.pre-commit.installationScript;
      };
    };
}
