{lib, ...}: let
  inherit (builtins) attrNames readDir;
  inherit (lib.attrsets) filterValues;
  inherit (lib.operators) eq;
  inherit (lib.trivial) compose;
in rec {
  filesIn = subpathsOfType "regular";
  subpathsOfType = type:
    compose [
      readDir
      (filterValues (eq type))
      attrNames
    ];
  subdirectoriesOf = subpathsOfType "directory";
}
