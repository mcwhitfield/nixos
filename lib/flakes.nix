{
  self,
  nixosRoot,
  ...
}: let
  inherit (builtins) attrValues filter toString;
  inherit (self) lib;
  inherit (lib) nixosSystem path strings;
  inherit (lib.attrsets) catAttrs explode genNames mapAttrsRecursive;
  inherit (lib.filesystem) listFilesRecursive;
  inherit (lib.operators) addPrefix;
  inherit (lib.strings) hasSuffix removeSuffix;
  inherit (lib.trivial) flip compose pipe;
in rec {
  importWithContext = flip import;
  importSubmodulesRecursive = ctx: dir: mapSubmodulesRecursive (importWithContext ctx) dir;
  importNixosConfigsRecursive = ctx @ {self, ...}: let
    mkConf = m: let
      userModules = pipe self.users [
        ((flip removeAttrs) ["default"])
        attrValues
        (catAttrs "nixos")
      ];
    in
      nixosSystem {
        modules =
          [m]
          ++ (attrValues self.nixosModules)
          ++ userModules;
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
