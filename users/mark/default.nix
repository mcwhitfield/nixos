{
  self,
  pkgs,
  config,
  osConfig,
  ...
}: let
  inherit (builtins) filter;
  inherit (self.lib.filesystem) listFilesRecursive;
  inherit (self.lib.strings) hasSuffix removePrefix;
  user = "mark";
  homeDir = "/home/${user}";
  userConfigs = filter (hasSuffix ".nix") (listFilesRecursive ./configs);
in {
  imports = with self.homeModules;
    userConfigs
    ++ [
      default
      firacode
    ];

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
        dolphin
        nix-output-monitor
      ];
      keyboard.options = [
        "caps:escape"
      ];
      persistDirs = with config.xdg; [
        "${homeDir}/.gnupg"
        "${homeDir}/.ssh"
        "${dataHome}/keyrings"
      ];
    };
  };
}
