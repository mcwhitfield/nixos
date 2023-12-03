{
  config,
  pkgs,
  secrets,
  ...
}: let
  user = "mark";
in {
  # programs.fish.enable = true;
  users.users.${user} = {
    hashedPasswordFile = config.age.secrets."mark-password".path;
    isNormalUser = true;
    shell = pkgs.bash;
    extraGroups = ["wheel" "networkmanager"];
  };
}
