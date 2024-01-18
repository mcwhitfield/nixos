inputs @ {
  self,
  config,
  domain,
  ...
}: let
  inherit (builtins) attrNames attrValues toString;
  inherit (self.lib) mkOption;
  inherit (self.lib.attrsets) attrByPath mapAttrs mapAttrsToList recursiveUpdate setAttrByPath;
  inherit (self.lib.lists) findFirstIndex;
  configKey = [domain "containers"];
  cfg = attrByPath configKey {} config;
  persistRoot = name: "${config.${domain}.persist.mounts.root}/containers/${name}";
in {
  options = setAttrByPath configKey (mkOption {
    default = {};
    description = "Alias of `config.containers` with extra ${domain}-specific defaults.";
  });

  config = {
    ${domain}.disko.extraPools = mapAttrsToList (name: _: persistRoot name) cfg;
    containers = let
      names = attrNames cfg;
      applyDefaults = name: submodule: let
        idx = findFirstIndex (n: n == name) (-1) names;
        hostIdx = 2 * idx;
        localIdx = hostIdx + 1;
        defaults = {
          autoStart = true;
          ephemeral = true;

          enableTun = true;
          privateNetwork = true;
          hostAddress = "192.168.100.${toString (10 + hostIdx)}";
          localAddress = "192.168.100.${toString (10 + localIdx)}";
          hostAddress6 = "fc00::${toString hostIdx}";
          localAddress6 = "fc00::${toString localIdx}";

          bindMounts.${persistRoot name}.isReadOnly = false;
          specialArgs = removeAttrs inputs ["config" "lib" "pkgs"];
        };
        finalConfig.config.imports = self.lib.flatten [
          (attrValues self.nixosModules)
          self.lib.flakes.userModules
          {${domain}.hardware.nixos-container.enable = true;}
          submodule.config
        ];
      in
        (recursiveUpdate defaults submodule) // finalConfig;
    in
      mapAttrs applyDefaults cfg;
  };
}
