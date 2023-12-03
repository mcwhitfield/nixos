{self, ...}: let
  inherit (builtins) filter;
  inherit (self.lib.attrsets) genAttrs';
  inherit (self.lib.filesystem) filesIn;
  inherit (self.lib.operators) neq;
  inherit (self.lib.trivial) pipe;
in rec {
  age.secrets = pipe ./. [
    filesIn
    (filter (neq "default.nix"))
    (genAttrs' (fname: {file = ./${fname};}))
  ];
}
