{
  self,
  config,
  pkgs,
  domain,
  ...
}: let
  inherit (self.lib) mkIf mkOption types;
  inherit (self.lib.attrsets) attrByPath setAttrByPath;
  configKey = [domain "workstation"];

  cfg = attrByPath configKey {} config;
in {
  options = setAttrByPath configKey {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Configure the device as a workstation (i.e. desktop environment, sound, etc.).
      '';
    };
    defaultSession = mkOption {
      type = types.str;
      description = "Alias for `services.xerver.displayManager.defaultSession`.";
    };
  };

  config = mkIf cfg.enable {
    ${domain} = {
      networking.wifi.enable = true;
    };
    environment.systemPackages = with pkgs; [pulseaudio];
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services = {
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };
      printing.enable = true;
      xserver = {
        enable = true;
        layout = "us";
        xkbVariant = "";
        displayManager.defaultSession = cfg.defaultSession;
      };
    };
    sound.enable = true;
  };
}
