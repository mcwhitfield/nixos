{self, ...}: let
  inherit (self.lib.trivial) flip;
in rec {
  eq = a: b: a == b;
  neq = a: b: a != b;
  addPrefix = a: b: a + b;
  addSuffix = flip addPrefix;
}
