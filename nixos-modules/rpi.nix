{
  self,
  pkgs,
  config,
  domain,
  ...
}: let
  inherit (self.lib) mkEnableOption mkIf mkOption types;
  inherit (self.lib.attrsets) attrByPath selfAndAncestorsEnabled setAttrByPath;
  configKey = [domain "rpi"];
  cfg = attrByPath configKey {} config;
in {
  options = setAttrByPath configKey {
    enable = mkEnableOption ''
      Common configuration for Raspberry Pi cluster nodes.
    '';
    cluster = mkOption {
      type = types.int;
      description = "Cluster ID of the RPI host.";
    };
    node = mkOption {
      type = types.int;
      description = "Node ID of the RPI within its cluster.";
    };
  };

  config = mkIf (selfAndAncestorsEnabled configKey config) {
    console.enable = false;
    environment.systemPackages = with pkgs; [
      libraspberrypi
      raspberrypi-eeprom
    ];
    hardware = {
      raspberry-pi."4".apply-overlays-dtmerge.enable = true;
      deviceTree = {
        enable = true;
        filter = "*rpi-4-*.dtb";
      };
    };
    networking = {
      hostName = "rpi-${toString cfg.cluster}-${toString cfg.node}";
      networkmanager.enable = false;
    };
    nixpkgs = {
      hostPlatform = "aarch64-linux";
    };

    boot = {
      initrd = {
        systemd.enable = true;
        systemd.initrdBin = [pkgs.zfs];
        network = {
          enable = true;
          postCommands = ''
            # Import all pools
            zpool import -a
            # Add the load-key command to the .profile
            echo "zfs load-key -a; killall zfs" >> /root/.profile
          '';
          ssh = {
            enable = true;
            port = 2222;
            authorizedKeys = [config.${domain}.pubKeys."ssh-user-mark-ed25519.pub"];
          };
        };
      };
    };

    ${domain} = {
      disko.enable = true;
      persist.enable = true;
    };
  };
}
