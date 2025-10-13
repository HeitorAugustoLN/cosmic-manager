{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem =
    { pkgs, ... }:
    {
      treefmt.programs = {
        deadnix.enable = true;
        nixfmt.enable = true;

        prettier = {
          enable = true;
          package = pkgs.prettierd;
        };

        rustfmt.enable = true;
        statix.enable = true;
        taplo.enable = true;
      };
    };
}
