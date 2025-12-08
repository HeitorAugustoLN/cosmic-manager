{
  pkgs ? import <nixpkgs> { },
  cosmic-manager ? pkgs.callPackage ./cosmic-manager { },
  ...
}:
let
  inherit (pkgs) lib;
in
pkgs.mkShell {
  strictDeps = true;

  nativeBuildInputs =
    let
      statix-fix = pkgs.writeShellScriptBin "statix-fix" ''
        for file in "''$@"; do
          ${lib.getExe pkgs.statix} fix "$file"
        done
      '';
    in
    with pkgs;
    [
      cargo
      clippy
      cosmic-manager
      deadnix
      nixfmt-rfc-style
      rustc
      rustfmt
      statix-fix
      taplo
      mdbook
    ];
}
