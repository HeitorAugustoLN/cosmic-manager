{
  perSystem =
    { pkgs, ... }:
    {
      packages.shortcut-actions-generator =
        let
          inherit (pkgs) lib;
        in
        pkgs.rustPlatform.buildRustPackage {
          pname = "shortcut-actions-generator";
          version = "0.1.0";

          src = lib.fileset.toSource {
            root = ./.;
            fileset = lib.fileset.unions [
              ./Cargo.lock
              ./Cargo.toml
              ./src
            ];
          };

          cargoLock.lockFile = ./Cargo.lock;

          nativeBuildInputs = [ pkgs.pkg-config ];
          buildInputs = [ pkgs.openssl ];

          meta = {
            description = "Generate JSON with all enum actions from COSMIC settings daemon";
            homepage = "https://github.com/HeitorAugustoLN/cosmic-manager";
            license = lib.licenses.mit;
            maintainers = [ lib.maintainers.HeitorAugustoLN ];
            platforms = lib.platforms.all;
          };
        };
    };
}
