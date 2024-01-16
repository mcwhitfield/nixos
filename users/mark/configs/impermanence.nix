{
  self,
  config,
  osConfig,
  domain,
  impermanence,
  ...
}: let
  inherit (self.lib) mkOption types;
  inherit (self.lib.strings) removePrefix;
  homeDir = config.home.homeDirectory;
  persistMount = osConfig.${domain}.persist.mounts.users;
in {
  imports = [impermanence.nixosModules.home-manager.impermanence];

  options.home.persistDirs = mkOption {
    type = types.listOf types.str;
    default = [];
  };
  config.home.persistence."${persistMount}/mark" = {
    directories = map (removePrefix "${homeDir}/") config.home.persistDirs;
    allowOther = false;
  };
}
