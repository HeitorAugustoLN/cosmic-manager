{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  options.wayland.desktopManager.cosmic = {
    configFile = lib.mkOption {
      type = with lib.types; attrsOf cosmicComponent;
      default = { };
      example = {
        "com.system76.CosmicComp" = {
          version = 1;
          entries = {
            autotile = true;
            autotile_behavior = {
              __type = "raw";
              value = "PerWorkspace";
            };
            xkb_config = {
              rules = "";
              model = "";
              layout = "br";
              variant = "";
              options = null;
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
            font_size = 16;
            font_family = "JetBrains Mono";
          };
        };
      };
      description = ''
        Defines configuration entries for COSMIC components (e.g., `com.system76.CosmicComp`) in $XDG_CONFIG_HOME.
        Each configuration includes:
          - `version`: The version of the component's configuration schema.
          - `entries`: A map of key-value pairs that define the component's settings. Entries may include:
            - Primitive values such as booleans, integers, floating point numbers, strings, lists and attribute sets (RON structs).
            - Advanced structured values like raw RON, optionals, characters, maps, tuples, and named structs,
              which follows the rules defined by `lib.cosmic.generators.toRON`.
      '';
    };

    dataFile = lib.mkOption {
      type = with lib.types; attrsOf cosmicComponent;
      default = { };
      description = ''
        Defines data entries for COSMIC components (e.g., `com.system76.CosmicComp`) in $XDG_DATA_HOME.
        Each data entry includes:
          - `version`: The version of the component's data schema.
          - `entries`: A map of key-value pairs that define the component's data. Entries may include:
            - Primitive values such as booleans, integers, floating point numbers, strings, lists and attribute sets (RON structs).
            - Advanced structured values like raw RON, optionals, characters, maps, tuples, and named structs,
              which follows the rules defined by `lib.cosmic.generators.toRON`.
      '';
    };

    stateFile = lib.mkOption {
      type = with lib.types; attrsOf cosmicComponent;
      default = { };
      example = {
        "com.system76.CosmicBackground" = {
          version = 1;
          entries = {
            wallpapers = [
              {
                __type = "tuple";
                value = [
                  "Virtual-1"
                  {
                    __type = "raw";
                    value = ''Path("/usr/share/backgrounds/cosmic/webb-inspired-wallpaper-system76.jpg")'';
                  }
                ];
              }
            ];
          };
        };
      };
      description = ''
        Defines state entries for COSMIC components (e.g., `com.system76.CosmicComp`) in $XDG_STATE_HOME.
        Each state entry includes:
          - `version`: The version of the component's state schema.
          - `entries`: A map of key-value pairs that define the component's state. Entries may include:
            - Primitive values such as booleans, integers, floating point numbers, strings, lists and attribute sets (RON structs).
            - Advanced structured values like raw RON, optionals, characters, maps, tuples, and named structs,
              which follows the rules defined by `lib.cosmic.generators.toRON`.
      '';
    };

    resetFiles = lib.mkEnableOption "COSMIC files reset";

    resetFilesDirectories = lib.mkOption {
      type =
        with lib.types;
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
      description = "XDG directories to reset.";
    };

    resetFilesExclude = lib.mkOption {
      type = with lib.types; listOf str;
      default = [ ];
      example = [
        "com.system76.CosmicComp"
        "dev.edfloreshz.CosmicTweaks/v1"
        "com.system76.CosmicSettings/v1/active-page"
        "com.system76.CosmicTerm/v1/{font_size,font_family}"
        "com.system76.{CosmicComp,CosmicPanel.Dock}/v1"
      ];
      description = "Patterns to exclude from reset (supports globbing and brace expansion).";
    };
  };

  config =
    let
      cfg = config.wayland.desktopManager.cosmic;
      cosmic-ctl = inputs.cosmic-ctl.packages.${pkgs.stdenv.hostPlatform.system}.default;

      makeOperations =
        xdgDirectory: components:
        lib.flatten (
          lib.mapAttrsToList (component: details: {
            inherit component;
            inherit (details) version;
            operation = "write";
            xdg_directory = xdgDirectory;
            entries = builtins.mapAttrs (_key: value: lib.cosmic.generators.toRON 0 value.value) details.entries;
          }) components
        );

      configurations = {
        "$schema" = "https://raw.githubusercontent.com/cosmic-utils/cosmic-ctl/refs/heads/main/schema.json";
        operations =
          (makeOperations "config" cfg.configFile)
          ++ (makeOperations "data" cfg.dataFile)
          ++ (makeOperations "state" cfg.stateFile);
      };

      json = pkgs.writeText "configuration.json" (builtins.toJSON configurations);
    in
    {
      assertions = [
        {
          assertion = !cfg.resetFiles || builtins.length cfg.resetFilesDirectories > 0;
          message = "At least one XDG directory must be selected to reset COSMIC files.";
        }
      ];

      home = {
        activation = lib.mkIf config.wayland.desktopManager.cosmic.enable {
          configure-cosmic = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            run ${lib.getExe cosmic-ctl} apply ${json}
          '';
          reset-cosmic = lib.mkIf cfg.resetFiles (
            lib.hm.dag.entryAfter [ "writeBoundary" ] ''
              run ${lib.getExe cosmic-ctl} reset --force --xdg-dirs ${builtins.concatStringsSep "," cfg.resetFilesDirectories} ${
                lib.optionalString (
                  builtins.length cfg.resetFilesExclude > 0
                ) "--exclude ${builtins.concatStringsSep "," cfg.resetFilesExclude}"
              }
            ''
          );
        };

        packages = [ cosmic-ctl ];
      };
    };
}
