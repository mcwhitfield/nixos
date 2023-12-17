{
  self,
  config,
  ...
}: let
  inherit (builtins) attrValues concatStringsSep;
  inherit (self.lib.attrsets) mapAttrs;
  inherit (self.lib.trivial) pipe;
  envVars = pipe config.home.sessionVariables [
    (mapAttrs
      (k: v: "set -g ${k} \"${v}\""))
    attrValues
    (concatStringsSep "\n")
  ];
in {
  programs.fish = {
    enable = true;
    interactiveShellInit = envVars;
    shellAliases = {
      hms = "home-manager switch";
      nhs = "home-manager switch";
      nrs = "nixos-rebuild switch";
    };

    functions = {
      p.body = "cd ~/public/$argv[1]";
      fish_command_not_found = {
        body = ''
          nix run nixpkgs#$argv[1] -- $argv[2..-1]
        '';
      };
      flake_path = {
        argumentNames = ["flake"];
        # description = builtins.concatStringsSep " " [
        #   "Print the path in the local FS or nix store of the provided system flake reference."
        #   "Returns 1 if the flake does not exist, or is a remote reference."
        # ];
        wraps = "nix flake metadata";
        body = ''
          set -q flake || set flake .
          nix flake metadata $flake 2> /dev/null | head -n 1 | awk -F ':' '{print $3}'
        '';
      };
      develop = {
        argumentNames = ["flake"];
        description = ''
          Change to the working directory of the provided flake and start its default devShell.
        '';
        wraps = "nix develop";
        body = ''
          cd (flake_path $flake) && nix develop -c fish
        '';
      };
    };
  };
}
