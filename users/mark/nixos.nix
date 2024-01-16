{
  self,
  pkgs,
  config,
  admin,
  domain,
  ...
}: let
  cfg = config.${domain}.users.mark;
  persistRoot = "/persist/home/mark";
in {
  options.${domain}.users.mark = {
    enable = self.lib.mkEnableOption ''
      Enable the user `mark` on the system.
    '';
    enableHomeManager = self.lib.mkOption {
      type = self.lib.types.bool;
      default = cfg.enable;
      description = ''
        Enable home-manager and `mark`'s HM profile on the system.
      '';
    };
  };
  config = self.lib.mkIf cfg.enable {
    ${domain} = {
      caps2superesc.enable = true;
      disko.extraPools = [persistRoot];
      security.yubikey.u2f.users.mark = self.lib.filesystem.readLines ./u2f_keys;
    };
    home-manager.users = self.lib.mkIf cfg.enableHomeManager {mark = ./default.nix;};
    programs.fish.enable = true;
    programs.wireshark.enable = true;
    users.users.mark = {
      uid = 1000;
      shell = pkgs.fish;
      initialHashedPassword = "$6$x4Czbd9boWzFUySX$pgTJ6Twtm4l98ho8my945FtF4SYwYe.fbJqbfPzm7SqIPW/lxts400f2dgvYr4Z5ahDA866TvtLxLNlqPt7sY.";
      openssh.authorizedPrincipals = [
        admin
      ];
      openssh.authorizedKeys.keys = with config.${domain}; [
        pubKeys."ssh-user-mark-ed25519.pub"
        pubKeys."ssh-user-mark-rsa.pub"
        pubKeys."ssh-user-mark-yubi-1.pub"
      ];
      isNormalUser = true;
      extraGroups = ["wheel" "networkmanager" "podman" "wireshark"];
    };
  };
}
