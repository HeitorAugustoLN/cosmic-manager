{ lib, ... }:
let
  inherit (lib) genAttrs makeExtensible;
in
makeExtensible (self: {
  applets = import ./applets.nix { inherit lib; };
  applications = import ./applications.nix { inherit lib; };
  modules = import ./modules.nix { inherit lib; };
  options = import ./options.nix { inherit lib; };
  ron = import ./ron.nix { inherit lib; };
  utils = import ./utils.nix { inherit lib; };

  inherit (self.applets) mkCosmicApplet;
  inherit (self.applications) mkCosmicApplication;
  inherit (self.modules)
    applyExtraConfig
    messagePrefix
    mkAssertion
    mkAssertions
    mkThrow
    mkWarning
    mkWarnings
    ;
  inherit (self.ron)
    fromRON
    importRON
    isRONType
    mkRON
    toRON
    ;
  inherit (self.options)
    defaultNullOpts
    literalRON
    mkNullOrOption
    mkNullOrOption'
    mkRONExpression
    mkSettingsOption
    nestedLiteral
    nestedLiteralRON
    nestedRONExpression
    RONExpression
    ;
  inherit (self.utils) cleanNullsExceptOptional;

  # TODO: Remove after COSMIC stable release
  generators =
    genAttrs
      [
        "fromRON"
        "toRON"
      ]
      (
        name:
        self.mkWarning "lib"
          "`cosmicLib.cosmic.generators.${name}` has been renamed to `cosmicLib.cosmic.ron.${name}`."
          self.ron.${name}
      );

  mkRon =
    self.mkWarning "lib" "`cosmicLib.cosmic.mkRon` has been renamed to `cosmicLib.cosmic.mkRON`"
      self.ron.mkRON;
})
