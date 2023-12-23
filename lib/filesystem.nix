{self, ...}: let
  inherit (builtins) attrNames readDir;
  inherit (self.lib.attrsets) filterValues;
  inherit (self.lib.operators) eq;
  inherit (self.lib.trivial) compose;
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
