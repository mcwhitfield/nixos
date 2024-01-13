{
  self,
  config,
  pkgs,
  domain,
  ...
}: let
  inherit (builtins) attrValues filter;
  inherit (self.lib) mkIf mkOption pipe types mkEnableOption;
  inherit (self.lib.attrsets) attrByPath mapAttrs selfAndAncestorsEnabled setAttrByPath;
  inherit (self.lib.lists) flatten;
  inherit (self.lib.strings) concatLines;
  configKey = [domain "yubikey"];
  u2fAuthFile = "Yubico/u2f_keys";

  cfg = attrByPath configKey {} config;
in {
  options = setAttrByPath configKey {
    enable = mkEnableOption ''
      Enable Yubikey integration for the configured host.
    '';
    u2f.users = mkOption {
      type = types.attrsOf (types.listOf types.str);
      default = {};
      description = "U2F tokens of authorized Yubikeys for the specified user.";
    };
  };

  config = mkIf (selfAndAncestorsEnabled configKey config) {
    environment.systemPackages = with pkgs; [yubikey-personalization yubikey-manager];
    environment.etc.${u2fAuthFile}.text = pipe cfg.u2f.users [
      (mapAttrs (user: lines: let
        tokens = filter (s: s != "") lines;
        mkEntry = token: "${user}:${token}";
      in
        map mkEntry tokens))
      attrValues
      flatten
      concatLines
    ];
    security.pam = {
      u2f = {
        enable = true;
        authFile = "/etc/${u2fAuthFile}";
        cue = true;
      };
      services = {
        login.u2fAuth = false;
        sudo.u2fAuth = true;
      };
    };
    services.pcscd.enable = true;
    services.udev.packages = with pkgs; [yubikey-personalization yubikey-manager];
  };
}
