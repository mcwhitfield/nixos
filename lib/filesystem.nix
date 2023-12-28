{self, ...}: let
  inherit (builtins) attrNames readDir readFile;
  inherit (self.lib.attrsets) filterValues;
  inherit (self.lib.operators) eq;
  inherit (self.lib.strings) splitString;
  inherit (self.lib.trivial) compose;
in rec {
  filesIn = subpathsOfType "regular";
  readLines = compose [readFile (splitString "\n")];
  subpathsOfType = type:
    compose [
      readDir
      (filterValues (eq type))
      attrNames
    ];
  subdirectoriesOf = subpathsOfType "directory";
}
