inputs @ {
  self,
  config,
  domain,
  home-manager,
  ...
}: let
  inherit (builtins) any attrValues;
  inherit (self.lib) mkIf mkOption types;
  inherit (self.lib.attrsets) attrByPath setAttrByPath;
  configKey = [domain "home-manager"];
  cfg = attrByPath configKey {} config;
in {
  imports = [
    home-manager.nixosModules.home-manager
  ];

  options = setAttrByPath configKey {
    enable = mkOption {
      type = types.bool;
      default = any (u: u.enable) (attrValues config.${domain}.users);
      description = ''
        Enable home-manager support on the system.
      '';
    };
  };

  config = mkIf (cfg.enable) {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = builtins.removeAttrs inputs ["config" "options" "lib"];
    };
  };
}
