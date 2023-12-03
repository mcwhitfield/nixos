{
  config,
  inputs,
  nixosRoot,
  system,
  user,
  ...
}: {
  programs.fish = {
    enable = true;
    plugins = [
      {
        name = "tide";
        src = inputs."fishPlugins.tide";
        #        {
        #          owner = "IlanCosman";
        #          repo = "tide";
        #          rev = "v6.0.1";
        #          hash = "sha256-oLD7gYFCIeIzBeAW1j62z5FnzWAp3xSfxxe7kBtTLgA=";
        #        };
      }
    ];
    interactiveShellInit = builtins.readFile ./tide_config.fish;
    shellAliases = {
      nixos-rebuild = "sudo command nixos-rebuild --flake ${nixosRoot}";
      home-manager = "command home-manager --flake ${nixosRoot}#${user}.${system}";
      hms = "home-manager switch";
      nhs = "home-manager switch";
      nrs = "nixos-rebuild switch";
    };
  };
}
