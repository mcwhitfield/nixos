{
  self,
  pkgs,
  config,
  domain,
  ...
}: let
  inherit (self.lib) mkIf mkEnableOption;
  inherit (self.lib.attrsets) selfAndAncestorsEnabled setAttrByPath;
  configKey = [domain "nix"];
in {
  options = setAttrByPath configKey {
    enable = mkEnableOption ''
      Standard Nix config for ${domain} hosts.
    '';
  };

  config = mkIf (selfAndAncestorsEnabled configKey config) {
    nix = {
      extraOptions = ''
        experimental-features = nix-command flakes repl-flake
      '';
      package = pkgs.nixFlakes;
      settings.allowed-users = ["@wheel"];
      settings.trusted-users = ["@wheel"];
    };
    nixpkgs.config.allowUnfree = false;
  };
}
