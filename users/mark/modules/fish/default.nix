inputs @ {nixosRoot, ...}: {
  programs.fish = {
    enable = true;
    plugins = [
      {
        name = "tide";
        src = inputs.fishPlugins-tide;
      }
    ];
    interactiveShellInit = builtins.readFile ./tide_config.fish;
    shellAliases = {
      nixos-rebuild = "sudo nixos-rebuild --flake ${nixosRoot}";
      home-manager = "command home-manager --flake ${nixosRoot}";
      hms = "home-manager switch";
      nhs = "home-manager switch";
      nrs = "nixos-rebuild switch";
      flake = "fish -c 'cd ${nixosRoot} && $EDITOR'";
    };

    functions = {
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
