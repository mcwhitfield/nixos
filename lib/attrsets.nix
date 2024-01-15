{self, ...}: let
  inherit (builtins) isAttrs listToAttrs;
  inherit (self) lib;
  inherit
    (lib.attrsets)
    concatMapAttrs
    filterAttrs
    genAttrs
    mapAttrs
    mapAttrs'
    nameValuePair
    setAttrByPath
    ;
  inherit (lib.operators) addPrefix;
  inherit (lib.strings) splitString;
  inherit (lib.trivial) flip compose;
in rec {
  explode = sep: concatMapAttrs (k: v: setAttrByPath (splitString sep k) v);
  filterKeys = f: filterAttrs (k: _: f k);
  filterValues = f: filterAttrs (_: v: f v);
  genAttrs' = flip genAttrs;
  genNames = f: mapToAttrs (v: nameValuePair (f v) v);
  implode = sep:
    concatMapAttrs (
      k: v:
        if isAttrs v
        then mapKeys (addPrefix "${k}${sep}") (implode v)
        else {k = v;}
    );
  mapKeys = f:
    mapAttrs' (k: v: {
      name = f k;
      value = v;
    });
  mapToAttrs = f: compose [(map f) listToAttrs];
  mapValues = f: mapAttrs (_: v: f v);
  #
}
