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
  imports = [agenix.nixosModules.default];
  age.secrets = pipe ./. [
    listFilesRecursive
    (filter (f: !(hasSuffix ".nix" f)))
    (filter (f: !(hasSuffix ".pub" f)))
    (map (file: nameValuePair (baseNameOf file) {inherit file;}))
    listToAttrs
  ];
  # Ensure /persist mounts with required ssh keys are available.
  systemd.services.agenix.after = ["basic.target"];
}
