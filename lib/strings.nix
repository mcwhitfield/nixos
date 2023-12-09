{lib, ...}: let
  inherit (builtins) filter head split substring typeOf;
  inherit (lib.strings) concatStringsSep toLower toUpper;
  inherit (lib.trivial) compose;
  inherit (lib.types) typeof;
in rec {
  camelToHyphen = mapSubstringsMatching "[[:upper:]]" (s: "-${toLower s}");
  hyphenToCamel = mapSubstringsMatching "-." (compose [(substring 1 1) toUpper]);
  mapSubstringsMatching = patt: f: s:
    compose [
      (split "(${patt})")
      (map (
        if (typeof s == "string")
        then s
        else (f (head s))
      ))
      (concatStringsSep "")
    ];
  splitString = sep: s: filter (e: typeOf e == "string") (split "(${sep})" s);
}
