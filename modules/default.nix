{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = import ../lib/import-modules.nix {
    inherit
      config
      lib
      pkgs
      ;
    modules =
      let
        appsByName = ./apps/by-name;
      in
      [
        ./files.nix
        ./panels.nix
        ./shortcuts.nix
      ]
      ++ lib.foldlAttrs (
        prev: name: type:
        prev ++ lib.optional (type == "directory") (appsByName + "/${name}")
      ) [ ] (builtins.readDir appsByName);
  };

  options.wayland.desktopManager.cosmic.enable =
    lib.mkEnableOption "COSMIC Desktop declarative configuration"
    // {
      description = ''
        Whether to enable declarative configuration management for the COSMIC Desktop environment.

        When enabled, this module allows you to manage your COSMIC Desktop settings through
        `home-manager`.
      '';
    };
}
