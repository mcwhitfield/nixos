{
  self,
  nixosRoot,
  ...
}: let
  inherit (builtins) filter toString;
  inherit (self) lib;
  inherit (lib) path strings;
  inherit (lib.attrsets) explode genNames mapAttrsRecursive;
  inherit (lib.filesystem) listFilesRecursive;
  inherit (lib.operators) addPrefix;
  inherit (lib.strings) hasSuffix hyphenToCamel removeSuffix;
  inherit (lib.trivial) compose pipe;
in rec {
  importWithContext = ctx: path: import path ctx;
  listSubmodulesRecursive = dir:
    pipe dir [
      listFilesRecursive
      (filter (hasSuffix ".nix"))
      (filter (p: !(hasSuffix "default.nix" p)))
      (genNames (compose [
        (path.removePrefix dir)
        (strings.removePrefix "./")
        (removeSuffix ".nix")
        hyphenToCamel
      ]))
      (explode "/")
    ];
  mapSubmodulesRecursive = f: dir: mapAttrsRecursive f (listSubmodulesRecursive dir);
  runtimePath = hmConfig:
    compose [
      toString
      (strings.removePrefix "${self}")
      (addPrefix nixosRoot)
      hmConfig.lib.file.mkOutOfStoreSymlink
    ];
}
