{
  self,
  config,
  options,
  domain,
  ...
}: let
  inherit (self.lib) mkIf mkOption types;
  inherit (self.lib.attrsets) attrByPath setAttrByPath;
  configKey = [domain "networking" "nat"];
  cfg = attrByPath configKey {} config;
in {
  options = setAttrByPath configKey {
    enable = mkOption {
      type = types.bool;
      default = config.${domain}.containers != {};
      description = ''
        Enable NAT traversal options for container hosts.
      '';
    };
    externalInterface = mkOption {
      type = options.networking.nat.externalInterface.type;
      description = ''
        Alias of networking.nat.externalInterface, but without a default.
      '';
      example = "wlp116s0";
    };
  };

  config = mkIf (cfg.enable) {
    networking.nat = {
      enable = true;
      internalInterfaces = ["ve-*"];
      externalInterface = cfg.externalInterface;
      enableIPv6 = true;
      # https://github.com/NixOS/nixpkgs/issues/72580
      extraCommands = ''
        iptables -t nat -A nixos-nat-post -o ${cfg.externalInterface} -j MASQUERADE
      '';
    };
  };
}
