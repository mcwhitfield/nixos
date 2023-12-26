inputs @ {
  config,
  pkgs,
  lib,
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
  services = {
    interception-tools.enable = true;
    # Some weird-ass bug where the final systemd unit overrides its own PATH in ExecStart?
    # Can't figure out where that's coming from, it's not part of ExecStart in the Nix config.
    interception-tools.udevmonConfig = let
      intercept = lib.getExe' pkgs.interception-tools "intercept";
      uinput = lib.getExe' pkgs.interception-tools "uinput";
      caps2superesc = lib.getExe' pkgs.caps2superesc "caps2superesc";
    in ''
      - JOB: "${intercept} -g $DEVNODE | ${caps2superesc} -m 1 -t 1000 | ${uinput} -d $DEVNODE"
        DEVICE:
          EVENTS:
            EV_KEY: [KEY_CAPSLOCK, KEY_ESC]
    '';
  };
}
