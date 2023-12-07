{
  self,
  lib,
  nixosRoot,
  ...
}: let
  inherit (builtins) filter toString;
  inherit (lib.attrsets) genAttrs' filterValues mapKeys mapValues;
  inherit (lib.filesystem) filesIn pathIsRegularFile subdirectoriesOf;
  inherit (lib.operators) addPrefix addSuffix neq;
  inherit (lib.path) append;
  inherit (lib.strings) hasSuffix removePrefix removeSuffix;
  inherit (lib.trivial) compose pipe;
in rec {
  importWithContext = ctx: path: import path ctx;
  isNixPackage = compose [
    (addSuffix "/default.nix")
    pathIsRegularFile
  ];
  listAllSubmodules = dir: (subpackagesOf dir) // (submodulesOf dir);
  importAllSubmodules = dir: ctx:
    pipe dir [
      listAllSubmodules
      (mapValues (importWithContext ctx))
    ];
  runtimePath = hmConfig:
    compose [
      toString
      (removePrefix "${self}")
      (addPrefix nixosRoot)
      hmConfig.lib.file.mkOutOfStoreSymlink
    ];
  submodulesOf = dir:
    compose [
      filesIn
      (filter (hasSuffix ".nix"))
      (filter (neq "default.nix"))
      (genAttrs' (append /${dir}))
      (mapKeys (removeSuffix ".nix"))
    ]
    dir;
  subpackagesOf = dir:
    compose [
      subdirectoriesOf
      (genAttrs' (append /${dir}))
      (filterValues isNixPackage)
    ]
    dir;
}
