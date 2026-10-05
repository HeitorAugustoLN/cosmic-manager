{ lib, ... }:
let
  inherit (builtins) isFunction;
  inherit (lib)
    assertMsg
    mkIf
    optionalString
    pipe
    trim
    warn
    ;

  messagePrefix = scope: "cosmic-manager${optionalString (scope != null) "(${scope})"}:";

  mkThrow =
    scope: error:
    let
      prefix = messagePrefix scope;
    in
    throw "${prefix} ${trim error}";
in
{
  inherit messagePrefix mkThrow;

  applyExtraConfig =
    {
      extraConfig,
      cfg,
      opts,
      enabled ?
        cfg.enable
          or (mkThrow "applyExtraConfig" "`enabled` argument was not provided and `cfg.enable` option was found."),
    }:
    let
      maybeApply =
        variable: maybeFunction: if isFunction maybeFunction then maybeFunction variable else maybeFunction;
    in
    pipe extraConfig [
      (maybeApply cfg)
      (maybeApply opts)
      (mkIf enabled)
    ];

  mkAssertion =
    scope: assertion: message:
    let
      prefix = messagePrefix scope;
    in
    assertMsg assertion "${prefix} ${trim message}";

  mkAssertions =
    scope: assertions:
    let
      prefix = messagePrefix scope;
      process = assertion: {
        inherit (assertion) assertion;
        message = "${prefix} ${trim assertion.message}";
      };
    in
    map process assertions;

  mkWarning =
    scope: message: value:
    let
      prefix = messagePrefix scope;
    in
    warn "${prefix} ${trim message}" value;

  mkWarnings =
    scope: warnings:
    let
      prefix = messagePrefix scope;
      process = warning: "${prefix} ${trim warning}";
    in
    map process warnings;
}
