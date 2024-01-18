{self, ...}: let
  inherit (builtins) trace deepSeq;
  inherit (self.lib.trivial) flip pipe;
in rec {
  apply = arg: f: f arg;
  # Why on earth does pipe put its arguments in this order? It's objectively way more useful the other way around.
  compose = flip pipe;
  deepTrace = a: b: trace (deepSeq a a) b;
  withTrace = a: trace a a;
  withDeepTrace = a: deepTrace a a;
}
