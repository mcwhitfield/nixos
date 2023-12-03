{lib, ...}: let
  inherit (builtins) listToAttrs;
  inherit (lib.attrsets) filterAttrs genAttrs mapAttrs mapAttrs';
  inherit (lib.trivial) flip compose;
in rec {
  filterKeys = f: filterAttrs (k: _: f k);
  filterValues = f: filterAttrs (_: v: f v);
  genAttrs' = flip genAttrs;
  mapKeys = f:
    mapAttrs' (k: v: {
      name = f k;
      value = v;
    });
  mapToAttrs = f: compose [f listToAttrs];
  mapValues = f: mapAttrs (_: v: f v);
}
