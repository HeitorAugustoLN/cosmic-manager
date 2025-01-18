{ lib, ... }:
let
  appletsByName = ./applets/by-name;
  appsByName = ./apps/by-name;
  misc = ./misc;
in
[
  ./files.nix
  ./panels.nix
  ./shortcuts.nix
]
++ lib.foldlAttrs (
  prev: name: type:
  prev ++ lib.optional (type == "directory") (appsByName + "/${name}")
) [ ] (builtins.readDir appsByName)
++ lib.foldlAttrs (
  prev: name: type:
  prev ++ lib.optional (type == "directory") (appletsByName + "/${name}")
) [ ] (builtins.readDir appletsByName)
++ lib.filesystem.listFilesRecursive misc