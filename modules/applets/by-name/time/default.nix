{ lib, ... }:
lib.cosmic.applets.mkCosmicApplet {
  name = "time";
  originalName = "Date, Time & Calendar";
  identifier = "com.system76.CosmicAppletTime";
  configurationVersion = 1;

  maintainers = [ lib.maintainers.HeitorAugustoLN ];

  settingsOptions =
    let
      inherit (lib.cosmic) defaultNullOpts;
    in
    {
      first_day_of_week = defaultNullOpts.mkU8 6 ''
        Which day of the week should be considered the first day.

        `0` for Monday, `1` for Tuesday, and so on.
      '';

      military_time = defaultNullOpts.mkBool false ''
        Whether to use the 24-hour format for the clock.
      '';

      show_date_in_top_panel = defaultNullOpts.mkBool true ''
        Whether to show the current date in the top panel.
      '';

      show_seconds = defaultNullOpts.mkBool false ''
        Whether to show the seconds in the clock.
      '';

      show_weekday = defaultNullOpts.mkBool true ''
        Whether to show the current weekday in the clock.
      '';
    };

  settingsExample = {
    first_day_of_week = 6;
    military_time = false;
    show_date_in_top_panel = true;
    show_seconds = false;
    show_weekday = true;
  };
}
