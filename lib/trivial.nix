{self, ...}: let
  inherit (builtins) head tail trace deepSeq;
  inherit (self.lib.trivial) flip pipe;
in rec {
  apply = arg: f: f arg;
  coalesce = as: let
    a = head as;
    as' = tail as;
  in
    if (as == [])
    then null
    else if (isNull a)
    then coalesce as'
    else a;
  # Why on earth does pipe put its arguments in this order? It's objectively way more useful the other way around.
  compose = flip pipe;
  deepTrace = a: b: trace (deepSeq a a) b;
  withTrace = a: trace a a;
  withDeepTrace = a: deepTrace a a;
}
