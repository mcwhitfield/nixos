# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  inputs,
  config,
  pkgs,
  ...
}: {
  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = true;
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  networking = {
    hostName = "turvy"; # Define your hostname.
    networkmanager.enable = true;
  };

  time.timeZone = "America/New_York";

  services.sshd.enable = true;

  # Configure keymap in X11
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
  nixpkgs.config.allowUnfree = false;

  environment.systemPackages = with pkgs; [
    inputs.agenix.packages.${config.nixpkgs.hostPlatform.system}.default
    gnome.adwaita-icon-theme
    gnome.gnome-tweaks
    git
    home-manager
    vim
    fzf
  ];

  environment.gnome.excludePackages = with pkgs; [
    gnome-photos
    gnome-tour
    gnome.cheese # webcam tool
    gnome.gnome-music
    gnome.gnome-terminal
    gnome.gedit # text editor
    gnome.epiphany # web browser
    gnome.geary # email reader
    gnome.evince # document viewer
    gnome.gnome-characters
    gnome.totem # video player
    gnome.tali # poker game
    gnome.iagno # go game
    gnome.hitori # sudoku game
    gnome.atomix # puzzle game.
  ];
  system.stateVersion = "23.05"; # Did you read the comment?
}
