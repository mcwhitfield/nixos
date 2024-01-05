inputs @ {
  self,
  config,
  domain,
  ...
}: let
  inherit (builtins) attrNames toString;
  inherit (self.lib) mkIf mkOption;
  inherit (self.lib.attrsets) attrByPath mapAttrs recursiveUpdate setAttrByPath;
  inherit (self.lib.lists) findFirstIndex;
  configKey = [domain "containers"];
  cfg = attrByPath configKey {} config;
in {
  options = setAttrByPath configKey (mkOption {
    default = {};
    description = "Alias of `config.containers` with extra ${domain}-specific defaults.";
  });

  config = {
    ${domain}.network.nat = mkIf (cfg != {}) {enable = true;};
    containers = let
      names = attrNames cfg;
      applyDefaults = name: submodule: let
        idx = findFirstIndex (n: n == name) (-1) names;
        hostIdx = 2 * idx;
        localIdx = hostIdx + 1;
        defaults = {
          autoStart = true;
          ephemeral = true;
          specialArgs = removeAttrs inputs ["config" "lib" "pkgs"];
          enableTun = true;
          privateNetwork = true;
          # hostBridge = config.${domain}.network.nat.bridgeNetwork;
          hostAddress = "192.168.100.${toString (10 + hostIdx)}";
          localAddress = "192.168.100.${toString (10 + localIdx)}";
          hostAddress6 = "fc00::${toString hostIdx}";
          localAddress6 = "fc00::${toString localIdx}";
          bindMounts.${config.${domain}.persist.mounts.root}.isReadOnly = false;
        };
        finalConfig.config.imports = [self.nixosModules.container-default submodule.config];
      in
        (recursiveUpdate defaults submodule) // finalConfig;
    in
      mapAttrs applyDefaults cfg;
  };
}
