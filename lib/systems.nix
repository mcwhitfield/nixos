{lib, ...}: let
  inherit (builtins) attrValues mapAttrs;
  inherit (lib) systems;
  inherit (lib.attrsets) genAttrs' mapKeys mergeAttrsList;
  inherit (lib.trivial) pipe;
in rec {
  systemSpecialization = s:
    mapAttrs
    (k: v: {
      name = "${k}.${s}";
      value = v;
    });
  eachSystem = mkConfigs:
    pipe systems.flakeExposed [
      # [system...]
      (genAttrs' mkConfigs)
      # {system = {user = {config}; ...}; ...}
      (mapAttrs (sys: cfgs: mapKeys (user: "${user}.${sys}") cfgs))
      # {system = {user.system = {config}; ...}; ...}
      attrValues
      # [{user.system = {config}; ...}]
      mergeAttrsList
      # {user.system = {config}; ...}
    ];
}
