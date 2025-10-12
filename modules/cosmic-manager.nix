{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    # TODO: Remove after COSMIC stable release.
    (lib.mkRenamedOptionModule
      [ "wayland" "desktopManager" "cosmic" "installCli" ]
      [ "programs" "cosmic-manager" "enable" ]
    )
  ];

  options.programs.cosmic-manager = {
    enable = lib.mkEnableOption "" // {
      default = false;
      defaultText = lib.literalMD "`config.wayland.desktopManager.cosmic.enable`";
      description = ''
        Whether to enable `cosmic-manager` command-line interface.
      '';
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../cosmic-manager { };
      defaultText = lib.literalExpression "pkgs.callPackage <cosmic-manager/cosmic-manager> { }";
      description = ''
        The package to use for `cosmic-manager` command-line interface.
      '';
    };
  };

  config =
    let
      cfg = config.programs.cosmic-manager;
    in
    lib.mkIf cfg.enable {
      home.packages = [ cfg.package ];
    };
}
