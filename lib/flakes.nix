{
  self,
  nixosRoot,
  ...
}: let
  inherit (builtins) filter toString;
  inherit (self) lib;
  inherit (lib) nixosSystem path strings;
  inherit (lib.attrsets) explode genNames mapAttrsRecursive;
  inherit (lib.filesystem) listFilesRecursive;
  inherit (lib.operators) addPrefix;
  inherit (lib.strings) hasSuffix removeSuffix;
  inherit (lib.trivial) flip compose pipe;
in rec {
  importWithContext = flip import;
  importSubmodulesRecursive = ctx: dir: mapSubmodulesRecursive (importWithContext ctx) dir;
  importNixosConfigsRecursive = ctx: let
    mkConf = m:
      nixosSystem {
        modules = [m ./nixos-modules];
        specialArgs = ctx;
      };
  in
    mapSubmodulesRecursive mkConf;
  enumeratePackage = dir:
    pipe dir [
      listFilesRecursive
      (filter (hasSuffix ".nix"))
      (genNames (compose [
        (path.removePrefix dir)
        (strings.removePrefix "./")
        (removeSuffix ".nix")
        (removeSuffix "/default")
      ]))
      (explode "/")
    ];
  mapSubmodulesRecursive = f: dir: mapAttrsRecursive (_: v: f v) (enumeratePackage dir);
  runtimePath = hmConfig:
    compose [
      toString
      (strings.removePrefix "${self}")
      (addPrefix nixosRoot)
      hmConfig.lib.file.mkOutOfStoreSymlink
    ];
}
