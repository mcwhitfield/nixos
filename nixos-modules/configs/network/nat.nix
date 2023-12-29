{
  self,
  config,
  options,
  domain,
  ...
}: let
  inherit (self.lib) mkEnableOption mkIf mkOption;
  inherit (self.lib.attrsets) attrByPath selfAndAncestorsEnabled setAttrByPath;
  configKey = [domain "network" "nat"];
  cfg = attrByPath configKey {} config;
in {
  options = setAttrByPath configKey {
    enable = mkEnableOption ''
      Enable NAT traversal options for hosts.
    '';
    externalInterface = mkOption {
      type = options.networking.nat.externalInterface.type;
      description = ''
        Alias of networking.nat.externalInterface, but without a default.
      '';
      example = "wlp116s0";
    };
  };

  config = mkIf (selfAndAncestorsEnabled configKey config) {
    networking.nat = {
      enable = true;
      internalInterfaces = ["ve-*"];
      externalInterface = cfg.externalInterface;
      enableIPv6 = true;
      # https://github.com/NixOS/nixpkgs/issues/72580
      extraCommands = "iptables -t nat -A POSTROUTING -o ${cfg.externalInterface} -j MASQUERADE";
    };
  };
}
