{
  self,
  domain,
  secrets,
  ...
}: let
  inherit (builtins) attrValues map readFile;
  inherit (self.lib) pipe;
  inherit (self.lib.attrsets) catAttrs filterAttrs;
  inherit (self.lib.strings) hasPrefix hasSuffix;
  pubKeysOf = user: rec {
    paths = pipe secrets [
      (filterAttrs (s: _: hasPrefix "ssh-user-${user}" s))
      (filterAttrs (s: _: hasSuffix ".pub" s))
      attrValues
    ];
    names = map readFile paths;
  };
  admins = {
    mark = {
      email = "mark@${domain}";
      sshPubKeys = pubKeysOf "mark";
    };
  };
  adminsList = attrValues admins;
in {
  admins =
    admins
    // {
      emails = catAttrs ["email"] adminsList;
      sshPubKeys = {
        paths = catAttrs ["sshPubKeys" "paths"] adminsList;
        texts = catAttrs ["sshPubKeys" "texts"] adminsList;
      };
    };
}
