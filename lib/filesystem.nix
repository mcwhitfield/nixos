{self, ...}: let
  inherit (builtins) attrNames readDir readFile;
  inherit (self.lib) path strings;
  inherit (self.lib.attrsets) explode filterValues genNames;
  inherit (self.lib.operators) eq;
  inherit (self.lib.filesystem) listFilesRecursive;
  inherit (self.lib.strings) splitString;
  inherit (self.lib.trivial) compose;
in rec {
  filesIn = subpathsOfType "regular";
  readLines = compose [readFile (splitString "\n")];
  enumerateFiles = dir:
    compose [
      listFilesRecursive
      (genNames (compose [
        (path.removePrefix dir)
        (strings.removePrefix "./")
      ]))
      (explode "/")
    ]
    dir;
  subpathsOfType = type:
    compose [
      readDir
      (filterValues (eq type))
      attrNames
    ];
  subdirectoriesOf = subpathsOfType "directory";
}
