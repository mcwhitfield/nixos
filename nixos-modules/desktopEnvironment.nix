{...}: {
  services.xserver = {
    enable = true;
    layout = "us";
    xkbVariant = "";
  };

  services.printing.enable = true;
  security.rtkit.enable = true;
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
