{ lib, pkgs }:
let
  inherit (lib) evalModules;

  action = {
    __type = "enum";
    variant = "Close";
  };

  evaluate = shortcuts:
    evalModules {
      specialArgs = { inherit lib; };
      modules = [
        ../modules/shortcuts.nix
        {
          options.assertions = lib.mkOption {
            type = lib.types.listOf lib.types.attrs;
            default = [ ];
          };

          options.wayland.desktopManager.cosmic.configFile = lib.mkOption {
            type = lib.types.attrs;
            default = { };
          };

          config.wayland.desktopManager.cosmic.shortcuts = shortcuts;
        }
      ];
    };

  assertionsPass = evaluated: builtins.all (assertion: assertion.assertion) evaluated.config.assertions;
  hasMessage = evaluated: builtins.any (assertion: lib.hasInfix "Conflicting key: q+Alt+Ctrl" assertion.message)
    evaluated.config.assertions;

  unset = evaluate null;
  distinct = evaluate [
    { key = "Super+Q"; inherit action; }
    { key = "Super+W"; inherit action; }
  ];
  exactDuplicate = evaluate [
    { key = "Super+Q"; inherit action; }
    { key = "Super+Q"; inherit action; }
  ];
  equivalentModifiers = evaluate [
    { key = "Ctrl+Alt+Q"; inherit action; }
    { key = "Alt+Ctrl+Q"; inherit action; }
  ];
  equivalentCase = evaluate [
    { key = "Super+q"; inherit action; }
    { key = "Super+Q"; inherit action; }
  ];
  differentActions = evaluate [
    { key = "Super+Q"; action = action // { variant = "Disable"; }; }
    { key = "Super+Q"; inherit action; }
  ];
in
assert assertionsPass unset;
assert assertionsPass distinct;
assert !assertionsPass exactDuplicate;
assert !assertionsPass equivalentModifiers;
assert hasMessage equivalentModifiers;
assert !assertionsPass equivalentCase;
assert !assertionsPass differentActions;
pkgs.runCommandLocal "shortcuts-collision-check" { } "touch $out"
