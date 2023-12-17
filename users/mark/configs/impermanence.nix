{
  self,
  config,
  impermanence,
  ...
}: let
  inherit (self.lib) mkOption types;
  inherit (self.lib.strings) removePrefix;
  homeDir = config.home.homeDirectory;
in {
  imports = [impermanence.nixosModules.home-manager.impermanence];

  options.home.persistDirs = mkOption {
    type = types.listOf types.str;
    default = [];
  };
  persistence."/persist${homeDir}" = {
    directories = map (removePrefix homeDir) config.home.persistDirs;
    allowOther = true;
  };
}
