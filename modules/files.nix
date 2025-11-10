{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (builtins) concatStringsSep length mapAttrs;
  inherit (lib)
    flatten
    getExe
    mapAttrsToList
    mkEnableOption
    mkIf
    mkOption
    optionalString
    types
    ;
  inherit (lib.cosmic)
    cleanNullsExceptOptional
    mkAssertions
    mkRONExpression
    toRON
    ;
  inherit (lib.hm.dag) entryAfter entryBefore;
in
{
  options.wayland.desktopManager.cosmic = {
    configFile = mkOption {
      type = with types; attrsOf cosmicComponent;
      default = { };
      example = mkRONExpression 0 {
        "com.system76.CosmicComp" = {
          version = 1;
          entries = {
            autotile = true;

            autotile_behavior = {
              __type = "enum";
              variant = "PerWorkspace";
            };

            xkb_config = {
              rules = "";
              model = "";
              layout = "br";
              variant = "";
              options = {
                __type = "optional";
                value = null;
              };
              repeat_delay = 600;
              repeat_rate = 25;
            };
          };
        };

        "com.system76.CosmicSettings" = {
          version = 1;
          entries = {
            active-page = "wallpaper";
          };
        };

        "com.system76.CosmicTerm" = {
          version = 1;
          entries = {
            font_name = "JetBrains Mono";
            font_size = 16;
          };
        };
      } null;
      description = ''
        Configuration files for COSMIC components stored in `$XDG_CONFIG_HOME`.

        Each component is identified by its unique identifier (e.g., `com.system76.CosmicComp`).

        Structure for each component:
        - `version`: Schema version number for the component configuration.
        - `entries`: Component-specific settings as key-value pairs.

        Entry values can be:
        - Simple types: booleans, integers, floating point numbers, strings.
        - Complex types: lists, and attribute sets (RON structs).
        - Special types:
          - `raw`: The value is stored as-is.
          - `optional`: The value is stored as an optional value. (e.g. `Some(value)` or `None`).
          - `char`: The value is stored as a single character. (e.g. `'a'`).
          - `map`: The value is stored as a map. (e.g. `{ "key" = "value" }`).
          - `tuple`: The value is stored as a tuple. (e.g. `(1, 2, 3)`).
          - `enum`: The value is stored as an enum variant.
        - Named structs: A structured entry with a name identifier.

        All values are serialized to RON format using `lib.cosmic.ron.toRON`.
      '';
    };

    dataFile = mkOption {
      type = with types; attrsOf cosmicComponent;
      default = { };
      description = ''
        Data files for COSMIC components stored in `$XDG_DATA_HOME`.

        Each component is identified by its unique identifier (e.g., `com.system76.CosmicComp`).

        Structure for each component:
          - `version`: Schema version number for the component configuration.
          - `entries`: Component-specific settings as key-value pairs.

        Entry values can be:
          - Simple types: booleans, integers, floating point numbers, strings.
          - Complex types: lists, and attribute sets (RON structs).
          - Special types:
            - `raw`: The value is stored as-is.
            - `optional`: The value is stored as an optional value. (e.g. `Some(value)` or `None`).
            - `char`: The value is stored as a single character. (e.g. `'a'`).
            - `map`: The value is stored as a map. (e.g. `{ "key" = "value" }`).
            - `tuple`: The value is stored as a tuple. (e.g. `(1, 2, 3)`).
            - `enum`: The value is stored as an enum variant.
          - Named structs: A structured entry with a name identifier.

        All values are serialized to RON format using `lib.cosmic.ron.toRON`.
      '';
    };

    stateFile = mkOption {
      type = with types; attrsOf cosmicComponent;
      default = { };
      example = mkRONExpression 0 {
        "com.system76.CosmicBackground" = {
          version = 1;
          entries = {
            wallpapers = [
              {
                __type = "tuple";
                value = [
                  "Virtual-1"
                  {
                    __type = "enum";
                    variant = "Path";
                    value = [ "/usr/share/backgrounds/cosmic/webb-inspired-wallpaper-system76.jpg" ];
                  }
                ];
              }
            ];
          };
        };
      } null;
      description = ''
        State files for COSMIC components stored in `$XDG_STATE_HOME`.

        Each component is identified by its unique identifier (e.g., `com.system76.CosmicComp`).

        Structure for each component:
          - `version`: Schema version number for the component configuration.
          - `entries`: Component-specific settings as key-value pairs.

        Entry values can be:
          - Simple types: booleans, integers, floating point numbers, strings.
          - Complex types: lists, and attribute sets (RON structs).
          - Special types:
            - `raw`: The value is stored as-is.
            - `optional`: The value is stored as an optional value. (e.g. `Some(value)` or `None`).
            - `char`: The value is stored as a single character. (e.g. `'a'`).
            - `map`: The value is stored as a map. (e.g. `{ "key" = "value" }`).
            - `tuple`: The value is stored as a tuple. (e.g. `(1, 2, 3)`).
            - `enum`: The value is stored as an enum variant.
          - Named structs: A structured entry with a name identifier.

        All values are serialized to RON format using `lib.cosmic.ron.toRON`.
      '';
    };

    resetFiles = mkEnableOption "COSMIC configuration files reset" // {
      description = ''
        Whether to enable COSMIC configuration files reset.

        When enabled, this option will delete any COSMIC-related files in the specified
        XDG directories that were not explicitly declared in your configuration. This
        ensures that your COSMIC desktop environment remains in a clean, known state
        as defined by your `home-manager` configuration.
      '';
    };

    resetFilesDirectories = mkOption {
      type =
        with types;
        listOf (enum [
          "config"
          "data"
          "state"
          "cache"
          "runtime"
        ]);
      default = [
        "config"
        "state"
      ];
      example = [
        "config"
        "data"
        "state"
      ];
      description = ''
        XDG base directories to reset when `resetFiles` is enabled.

        Available directories:
        - `config`: User configuration (`$XDG_CONFIG_HOME`)
        - `data`: Application data (`$XDG_DATA_HOME`)
        - `state`: Runtime state (`$XDG_STATE_HOME`)
        - `cache`: Cached data (`$XDG_CACHE_HOME`)
        - `runtime`: Runtime files (`$XDG_RUNTIME_DIR`)
      '';
    };

    resetFilesExclude = mkOption {
      type = with types; listOf str;
      default = [ ];
      example = [
        "com.system76.CosmicComp"
        "dev.edfloreshz.CosmicTweaks/v1"
        "com.system76.CosmicSettings/v1/active-page"
        "com.system76.CosmicTerm/v1/{font_size,font_family}"
        "com.system76.{CosmicComp,CosmicPanel.Dock}/v1"
      ];
      description = ''
        Patterns to exclude from the reset operation when `resetFiles` is enabled.
        Supports glob patterns and brace expansion for matching files and directories.

        Use this option to preserve specific files or directories from being reset.
      '';
    };
  };

  config =
    let
      cfg = config.wayland.desktopManager.cosmic;

      makeOperations =
        xdg_directory: components:
        flatten (
          mapAttrsToList (component: details: {
            inherit component xdg_directory;
            inherit (details) version;
            operation = "write";

            entries = mapAttrs (_: value: toRON 0 value) (cleanNullsExceptOptional details.entries);
          }) components
        );

      configurations = {
        "$schema" = "https://raw.githubusercontent.com/cosmic-utils/cosmic-ctl/refs/heads/main/schema.json";
        operations =
          (makeOperations "config" cfg.configFile)
          ++ (makeOperations "data" cfg.dataFile)
          ++ (makeOperations "state" cfg.stateFile);
      };

      json = (pkgs.formats.json { }).generate "configurations.json" configurations;
    in
    {
      assertions = mkAssertions "files" [
        {
          assertion = cfg.resetFiles -> length cfg.resetFilesDirectories > 0;
          message = "At least one XDG directory must be selected to reset COSMIC files.";
        }
      ];

      home.activation =
        let
          cosmic-ctl = getExe config.programs.cosmic-ext-ctl.package;
        in
        mkIf cfg.enable {
          configureCosmic = entryAfter [ "writeBoundary" ] "run ${cosmic-ctl} apply ${json}";

          resetCosmic = mkIf cfg.resetFiles (
            entryBefore [ "configureCosmic" ]
              "run ${cosmic-ctl} reset --force --xdg-dirs ${concatStringsSep "," cfg.resetFilesDirectories} ${
                optionalString (
                  length cfg.resetFilesExclude > 0
                ) "--exclude ${concatStringsSep "," cfg.resetFilesExclude}"
              }"
          );
        };
    };
}
