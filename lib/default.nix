inputs @ {
  nixpkgs,
  home-manager,
  ...
}: let
  inherit (builtins) filter;
  inherit (nixpkgs.lib) path strings;
  inherit (strings) removeSuffix splitString;
  inherit (nixpkgs.lib.attrsets) mergeAttrsList recursiveUpdate setAttrByPath;
  inherit (nixpkgs.lib.filesystem) listFilesRecursive;
  inherit (nixpkgs.lib.trivial) pipe flip;

  relativePath = p: pipe p [(path.removePrefix ./.) (strings.removePrefix "./")];
  importSubmodule = p: let
    module = import p inputs;
  in
    pipe p [
      relativePath
      (removeSuffix ".nix")
      (splitString "/")
      (flip setAttrByPath module)
    ];
  myLib = pipe ./. [
    listFilesRecursive
    (filter (f: f != ./default.nix))
    (map importSubmodule)
    mergeAttrsList
  ];
in
  pipe myLib [
    (recursiveUpdate nixpkgs.lib)
    (recursiveUpdate home-manager.lib)
  ]
