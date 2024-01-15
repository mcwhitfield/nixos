{
  self,
  pkgs,
  config,
  domain,
  users,
  ...
}: let
  inherit (self.lib) mkIf mkOption types;
  inherit (self.lib.attrsets) attrByPath setAttrByPath;
  configKey = [domain "nix"];
  cfg = attrByPath configKey {} config;
in {
  options = setAttrByPath configKey {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Standard Nix config for ${domain} hosts.
      '';
    };
  };

  config = mkIf (cfg.enable) {
    nix = {
      channel.enable = false;
      extraOptions = ''
        experimental-features = nix-command flakes repl-flake
      '';
      gc = {
        automatic = true;
        dates = "weekly";
        persistent = true;
      };
      registry.nixpkgs.to = {
        type = "path";
        path = pkgs.path;
      };
      package = pkgs.nixFlakes;
      settings = rec {
        allowed-users = ["@wheel"];
        auto-optimise-store = true;
        trusted-users = allowed-users;
      };
      sshServe = {
        keys = users.admins.sshPubKeys.text;
        write = true;
      };
    };
    nixpkgs.config.allowUnfree = false;
  };
}
