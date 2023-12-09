{
  self,
  agenix,
  ...
}: let
  inherit (builtins) baseNameOf filter listToAttrs;
  inherit (self.lib.attrsets) nameValuePair;
  inherit (self.lib.filesystem) listFilesRecursive;
  inherit (self.lib.strings) hasSuffix;
  inherit (self.lib.trivial) pipe;
in {
  imports = [agenix.homeManagerModules.default];
  config.age.secrets = pipe ./. [
    listFilesRecursive
    (filter (f: !(hasSuffix ".nix" f)))
    (map (file: nameValuePair (baseNameOf file) {inherit file;}))
    listToAttrs
  ];
}
