{
  self,
  domain,
  ...
}: {
  config = {
    ${domain} = {
      caps2superesc.enable = true;
      yubikey.u2f.users.mark = self.lib.filesystem.readLines ./u2f_keys;
    };
    home-manager.users.mark = ./default.nix;
    users.users.mark = {
      uid = 1000;
      initialHashedPassword = "$6$x4Czbd9boWzFUySX$pgTJ6Twtm4l98ho8my945FtF4SYwYe.fbJqbfPzm7SqIPW/lxts400f2dgvYr4Z5ahDA866TvtLxLNlqPt7sY.";
      isNormalUser = true;
      extraGroups = ["wheel" "networkmanager" "podman" "wireshark"];
    };
  };
}
