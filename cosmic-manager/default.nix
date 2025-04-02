{
  lib,
  rustPlatform,
  cosmic-comp,
}:
rustPlatform.buildRustPackage {
  pname = "cosmic-manager";
  version = "0-unstable-2025-04-02";

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./src
      ./Cargo.toml
      ./Cargo.lock
    ];
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-lvuVPidbCfSqazelzxhsBrJdXGdCpw/YOL5dijy5ORI=";

  meta = {
    description = "cosmic-manager command-line interface";
    homepage = "https://github.com/HeitorAugustoLN/cosmic-manager";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.HeitorAugustoLN ];
    mainProgram = "cosmic-manager";
    inherit (cosmic-comp.meta) platforms;
  };
}
