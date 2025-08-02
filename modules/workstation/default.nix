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
    environment.systemPackages = with pkgs; [pulseaudio libsForQt5.kmix pasystray google-drive-ocamlfuse texliveFull texmaker];
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    security.pam.loginLimits = [
      {
        domain = "*";
        type = "hard";
        item = "nofile";
        value = "1048576";
      }
      {
        domain = "*";
        type = "soft";
        item = "nofile";
        value = "1048576";
      }
    ];
    services = {
      displayManager.defaultSession = cfg.defaultSession;
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };
      printing.enable = true;
      xserver = {
        enable = true;
        xkb = {
          variant = "";
          layout = "us";
        };
      };
    };
  };
}
