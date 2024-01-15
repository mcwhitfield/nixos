{
  self,
  config,
  pkgs,
  domain,
  ...
}: let
  inherit (builtins) attrValues filter;
  inherit (self.lib) mkIf mkOption pipe types;
  inherit (self.lib.attrsets) attrByPath mapAttrs setAttrByPath;
  inherit (self.lib.lists) flatten;
  inherit (self.lib.strings) concatLines;
  configKey = [domain "security" "yubikey"];
  yubiPackages = with pkgs; [yubikey-personalization yubikey-manager];

  cfg = attrByPath configKey {} config;
in {
  options = setAttrByPath configKey {
    enable = mkOption {
      type = types.bool;
      default = true;
      example = false;
      description = ''
        Enable Yubikey integration for the configured host.
      '';
    };
    u2f = {
      users = mkOption {
        type = types.attrsOf (types.listOf types.str);
        default = {};
        description = "U2F tokens of authorized Yubikeys for the specified user.";
      };
      path = mkOption {
        type = types.str;
        description = "Location of u2f config file in /etc.";
        default = "Yubico/u2f_keys";
        example = "gpg/u2f_keys";
      };
      text = mkOption {
        type = types.lines;
        description = "Text to be written to /etc/$${config.${domain}.yubikey.u2f.path}";
        readOnly = true;
        default = pipe cfg.u2f.users [
          (mapAttrs (user: lines: let
            tokens = filter (s: s != "") lines;
            mkEntry = token: "${user}:${token}";
          in
            map mkEntry tokens))
          attrValues
          flatten
          concatLines
        ];
      };
    };
  };

  config = mkIf (cfg.enable) {
    environment.systemPackages = yubiPackages;
    environment.etc.${cfg.u2f.path}.text = cfg.u2f.text;

    security.pam = {
      u2f = {
        enable = true;
        authFile = "/etc/${cfg.u2f.path}";
        cue = true;
      };
      services = {
        login.u2fAuth = false;
        sudo.u2fAuth = true;
      };
    };

    services.pcscd.enable = true;
    services.udev.packages = yubiPackages;
  };
}
