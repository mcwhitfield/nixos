{
  self,
  pkgs,
  config,
  osConfig,
  ...
}: let
  inherit (builtins) filter;
  inherit (self.lib.filesystem) listFilesRecursive;
  inherit (self.lib.lists) flatten;
  inherit (self.lib.strings) hasSuffix;
  user = "mark";
  homeDir = "/home/${user}";
  userConfigs = filter (hasSuffix ".nix") (listFilesRecursive ./configs);
in {
  imports = flatten [self.homeModules.default userConfigs];

  config = {
    _module.args = {
      inherit user;
    };
    accounts.email.accounts.${user} = {
      address = "${user}@${osConfig.networking.domain}";
      primary = true;
    };
    home = {
      username = user;
      homeDirectory = homeDir;
      stateVersion = "23.11";
      packages = with pkgs; [
        nix-output-monitor
        ranger
      ];
      persistDirs = with config.xdg; [
        "${homeDir}/.gnupg"
        "${homeDir}/.ssh"
        "${dataHome}/keyrings"
        "${configHome}/heroic"
      ];
    };
    programs = {
      lsd.enable = true;
      lsd.enableAliases = true;
    };
    systemd.user.startServices = true;
  };
}
