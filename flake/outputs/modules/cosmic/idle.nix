{ cosmicLib, ... }:
let
  mkIdleOption =
    { lib, pkgs }:
    lib.mkOption {
      type = lib.types.nullOr (
        lib.types.submodule {
          freeformType = lib.types.attrsOf (pkgs.formats.ron { }).type;

          options = {
            screen_off_time = lib.mkOption {
              type = lib.types.ronOptionalOf lib.types.ints.u32;
              example = lib.literalExpression "lib.ron.mkOptional 90000";
              description = "Idle time in milliseconds before screen turns off.";
            };

            suspend_on_ac_time = lib.mkOption {
              type = lib.types.ronOptionalOf lib.types.ints.u32;
              example = lib.literalExpression "lib.ron.mkOptional 180000";
              description = "Idle time in milliseconds before the system suspends when on AC power.";
            };

            suspend_on_battery_time = lib.mkOption {
              type = lib.types.ronOptionalOf lib.types.ints.u32;
              example = lib.literalExpression "lib.ron.mkOptional 90000";
              description = "Idle time in milliseconds before the system suspends when on battery power.";
            };
          };
        }
      );
      default = null;
      example = lib.literalExpression ''
        {
          screen_off_time = lib.ron.mkOptional 90000;
          suspend_on_ac_time = lib.ron.mkOptional 180000;
          suspend_on_battery_time = lib.ron.mkOptional 90000;
        }
      '';
      description = "COSMIC idle configuration for power management and screen timeout settings.";
    };
in
{
  flake.modules = {
    homeManager.cosmic-manager =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        options.wayland.desktopManager.cosmic.idle = mkIdleOption { inherit lib pkgs; };

        config.wayland.desktopManager.cosmic.components.config."com.system76.CosmicIdle" =
          let
            cfg = config.wayland.desktopManager.cosmic;
          in
          lib.mkIf (cfg.idle != null) {
            entries = cosmicLib.cleanNullsExceptOptional cfg.idle;
            version = 1;
          };
      };

    nixos.cosmic-manager =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        options.services.desktopManager.cosmic.idle = mkIdleOption { inherit lib pkgs; };

        config.services.desktopManager.cosmic.settings."com.system76.CosmicIdle" =
          let
            cfg = config.services.desktopManager.cosmic;
          in
          lib.mkIf (cfg.idle != null) {
            entries = cosmicLib.cleanNullsExceptOptional cfg.idle;
            version = 1;
          };
      };
  };
}
