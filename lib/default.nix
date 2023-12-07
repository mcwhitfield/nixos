ctx @ {
  self,
  inputs,
  ...
}: let
  inherit (builtins) basename;
  inherit (inputs.nixpkgs.lib) path;
  inherit (inputs.nixpkgs.lib.attrsets) attrByPath;
  inherit (inputs.nixpkgs.lib.fixedPoints) composeManyExtensions extends fix makeExtensible;
  inherit (inputs.nixpkgs.lib.strings) removePrefix removeSuffix;
  inherit (inputs.nixpkgs.lib.trivial) pipe;

  baseLib = inputs.home-manager.lib // inputs.nixpkgs.lib;
  module = makeExtensible (next: baseLib);

  extendsWithContext = extension: lib: inputLibs: let
    extensionValue = import extension (ctx // {inherit lib inputLibs;});
    extensionName = pipe extension [
      (path.removePrefix ./.)
      (removePrefix "./")
      (removeSuffix ".nix")
    ];
    originalAttr = attrByPath [extensionName] {} inputLibs;
  in {"${extensionName}" = originalAttr // extensionValue;};

  extensions = [
    ./operators.nix
    ./trivial.nix
    ./strings.nix
    ./attrsets.nix
    ./filesystem.nix
    ./flakes.nix
    ./systems.nix
  ];
  composedExtensions = composeManyExtensions (map extendsWithContext extensions);
in
  module.extend composedExtensions
