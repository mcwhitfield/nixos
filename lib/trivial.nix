{self, ...}: let
  inherit (self.lib.trivial) flip pipe;
in {
  apply = arg: f: f arg;
  # Why on earth does pipe put its arguments in this order? It's objectively way more useful the other way around.
  compose = flip pipe;
}
