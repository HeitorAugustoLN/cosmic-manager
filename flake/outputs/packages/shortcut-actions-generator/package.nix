{ config, ... }:
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
            homepage = config.nexus.meta.repo.url;
            inherit (config.nexus.meta.repo) license maintainers;
            platforms = lib.platforms.all;
          };
        };
    };
}
