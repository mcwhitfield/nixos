{
  self,
  config,
  domain,
  ...
}: let
  inherit (self.lib) mkEnableOption mkIf;
  inherit (self.lib.attrsets) selfAndAncestorsEnabled setAttrByPath;
  configKey = [domain]; # TODO: Unique config subkey.
in {
  imports = [
    # TODO: Module imports.
  ];

  options = setAttrByPath configKey {
    enable = mkEnableOption ''
      REPLACEME
    ''; # TODO: Module description.
  };

  config = mkIf (selfAndAncestorsEnabled configKey config) {
    # TODO: Module configs.
  };
}
