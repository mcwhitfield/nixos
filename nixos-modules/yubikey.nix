{
  self,
  config,
  pkgs,
  ...
}: let
  inherit (builtins) attrValues concatStringsSep;
  inherit (self.lib) mkOption pipe types;
  inherit (self.lib.lists) flatten;

  u2fAuthFile = "Yubico/u2f_keys";
in {
  options.security.pam.u2f.users = mkOption {
    type = types.attrsOf (types.listOf types.str);
    default = {};
  };
  config = {
    environment.systemPackages = [pkgs.yubikey-personalization];
    environment.etc.${u2fAuthFile}.text = pipe config.security.pam.u2f.users [
      attrValues
      flatten
      (concatStringsSep "\n")
    ];
    security.pam = {
      u2f = {
        authFile = "/etc/${config.environment.etc.${u2fAuthFile}.target}";
        cue = true;
      };
      services = {
        login.u2fAuth = false;
        sudo.u2fAuth = true;
      };
    };
    services.pcscd.enable = true;
    services.udev.packages = [pkgs.yubikey-personalization];
  };
}
