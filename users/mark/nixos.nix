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
  programs.wireshark.enable = true;
  security.pam.u2f.users.mark = ["mark:t5wiaINdcXNNSDACjjf4Wn6EqI40bA37K22gnHJbNKWkZLX7ZmBAsunfR6ETVXax2ScFtn+Rm6MHsx2kV2jKYw==,6FDMIONsVUzSb8Fj1S3i+2lx/+Ian59vOk2XXpOjkiN2vq72he+HQsG4NG8OUcS3ekkq/4n/0xKH6+d4vnRCqQ==,es256,+presence"];
  users.users = {
    mark = {
      uid = 1000;
      initialHashedPassword = "$6$x4Czbd9boWzFUySX$pgTJ6Twtm4l98ho8my945FtF4SYwYe.fbJqbfPzm7SqIPW/lxts400f2dgvYr4Z5ahDA866TvtLxLNlqPt7sY.";
      isNormalUser = true;
      extraGroups = ["wheel" "networkmanager" "podman" "wireshark"];
    };
  };
}
