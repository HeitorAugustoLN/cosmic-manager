{ lib, ... }:
{
  options.nexus.meta = {
    repo = lib.mkOption {
      type = lib.types.submodule (
        { config, ... }:
        {
          options = {
            license = lib.mkOption {
              type = lib.types.attrsOf lib.types.anything;
              description = "License information for the repository.";
            };

            maintainers = lib.mkOption {
              type = lib.types.listOf (lib.types.attrsOf lib.types.anything);
              description = "List of maintainers for the repository.";
            };

            name = lib.mkOption {
              type = lib.types.str;
              description = "Name of the repository.";
            };

            owner = lib.mkOption {
              type = lib.types.str;
              description = "Owner of the repository.";
            };

            url = lib.mkOption {
              type = lib.types.str;
              description = "URL of the repository.";
            };
          };

          config.url = "https://github.com/${config.owner}/${config.name}";
        }
      );
      description = "Repository metadata configuration.";
      internal = true;
    };
  };

  config.nexus.meta.repo = {
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.HeitorAugustoLN ];
    name = "cosmic-manager";
    owner = "HeitorAugustoLN";
  };
}
