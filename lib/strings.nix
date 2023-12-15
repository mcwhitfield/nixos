{self, ...}: let
  inherit (self) lib;
  inherit (builtins) filter head split substring typeOf;
  inherit (lib.strings) concatStringsSep toLower toUpper;
  inherit (lib.trivial) compose const;
in rec {
  camelToHyphen = mapSubstringsMatching "[[:upper:]]" (s: "-${toLower s}");
  hyphenToCamel = mapSubstringsMatching "-." (compose [(substring 1 1) toUpper]);
  hyphenToConstant = compose [(mapSubstringsMatching "-" (const "_")) toUpper];
  mapSubstringsMatching = patt: f:
    compose [
      (split "(${patt})")
      (map (
        part:
          if (typeOf part == "string")
          then part
          else (f (head part))
      ))
      (concatStringsSep "")
    ];
  splitString = sep: s: filter (e: typeOf e == "string") (split "(${sep})" s);
}
