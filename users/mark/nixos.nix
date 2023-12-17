inputs @ {
  config,
  home-manager,
  ...
}: {
  imports = [home-manager.nixosModules.home-manager];
  fileSystems."/home/mark" = {
    device = "none";
    fsType = "tmpfs";
    options = ["defaults" "size=2G" "mode=755" "uid=${builtins.toString config.users.users.mark.uid}"];
  };
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.mark = ./default.nix;
    extraSpecialArgs = builtins.removeAttrs inputs ["config" "options" "lib"];
  };
  users.users = {
    mark = {
      uid = 1000;
      initialHashedPassword = "$6$x4Czbd9boWzFUySX$pgTJ6Twtm4l98ho8my945FtF4SYwYe.fbJqbfPzm7SqIPW/lxts400f2dgvYr4Z5ahDA866TvtLxLNlqPt7sY.";
      isNormalUser = true;
      extraGroups = ["wheel" "networkmanager" "podman"];
    };
  };
}
