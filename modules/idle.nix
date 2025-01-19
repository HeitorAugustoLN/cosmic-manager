{ config, lib, ... }:
{
  options.wayland.desktopManager.cosmic.idle =
    let
      inherit (lib.cosmic) defaultNullOpts;

      inputSubmodule = lib.types.submodule {
        freeformType = with lib.types; attrsOf anything;
        options = {
          screen_off_time =
            defaultNullOpts.mkRonOptionalOf lib.types.ints.u32
              {
                __type = "optional";
                value = 90000;
              }
              ''
                The time in milliseconds before the screen turns off.
              '';

          suspend_on_ac_time =
            defaultNullOpts.mkRonOptionalOf lib.types.ints.u32
              {
                __type = "optional";
                value = 180000;
              }
              ''
                The time in milliseconds before the system suspends when on AC power.
              '';

          suspend_on_battery_time =
            defaultNullOpts.mkRonOptionalOf lib.types.ints.u32
              {
                __type = "optional";
                value = 90000;
              }
              ''
                The time in milliseconds before the system suspends when on battery power.
              '';
        };
      };
    in
    defaultNullOpts.mkNullable inputSubmodule
      {
        screen_off_time = 90000;
        suspend_on_ac_time = 180000;
        suspend_on_battery_time = 90000;
      }
      ''
        Settings for the COSMIC idle manager.
      '';

  config.wayland.desktopManager.cosmic.configFile."com.system76.CosmicIdle" =
    let
      cfg = config.wayland.desktopManager.cosmic;
    in
    lib.mkIf (cfg.idle != null) {
      entries = cfg.idle;
      version = 1;
    };
}
