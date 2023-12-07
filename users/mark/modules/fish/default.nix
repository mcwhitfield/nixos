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
      }
    ];
    interactiveShellInit = builtins.readFile ./tide_config.fish;
    shellAliases = {
      nixos-rebuild = "sudo nixos-rebuild --flake ${nixosRoot}";
      home-manager = "command home-manager --flake ${nixosRoot}#${user}.${system}";
      hms = "home-manager switch";
      nhs = "home-manager switch";
      nrs = "nixos-rebuild switch";
    };
  };
}
