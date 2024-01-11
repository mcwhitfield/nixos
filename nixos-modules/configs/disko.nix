{
  self,
  config,
  domain,
  ...
}: let
  inherit (self.lib) mkEnableOption mkIf mkOption types;
  inherit (self.lib.attrsets) attrByPath mapToAttrs nameValuePair selfAndAncestorsEnabled setAttrByPath;
  inherit (self.lib.strings) removePrefix;
  configKey = [domain "disko"];
  cfg = attrByPath configKey {} config;
  pool = "zpool-${config.networking.hostName}";
in {
  options = setAttrByPath configKey {
    enable = mkEnableOption ''
      Enable disk partition management via Disko.
    '';
    disk = mkOption {
      type = types.str;
      description = "Device name of the primary disk.";
    };
    tmpfs = {
      maxSize = mkOption {
        type = types.str;
        default = "2G";
        description = ''
          Size of the tmpfs that will be mounted at `/`, i.e. the
          max system memory sacrificed for storage of non-persistent system files.
        '';
      };
    };
    extraPools = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Extra directories to be managed as separate ZFS pools.";
    };
  };

  config = mkIf (selfAndAncestorsEnabled configKey config) {
    disko.devices = {
      nodev."/" = {
        mountpoint = "/";
        device = "none";
        fsType = "tmpfs";
        mountOptions = ["defaults" "size=${cfg.tmpfs.maxSize}" "mode=755"];
      };
      disk.primary = {
        type = "disk";
        device = cfg.disk;
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["fmask=0077" "dmask=0077"];
              };
            };
            zfs = {
              size = "100%";
              content = {
                inherit pool;
                type = "zfs";
              };
            };
          };
        };
      };
      zpool.${pool} = {
        type = "zpool";
        rootFsOptions = {
          encryption = "on";
          compression = "on";
          xattr = "sa";
          acltype = "posixacl";
          keyformat = "passphrase";
          keylocation = "file:///tmp/secret.key";
          mountpoint = "none";
        };
        postCreateHook = ''
          zfs set keylocation="prompt" "${pool}";
        '';
        datasets = let
          volume = mountpoint: {
            type = "zfs_fs";
            inherit mountpoint;
            options = {
              mountpoint = "legacy";
              "com.sun:auto-snapshot" = "true";
            };
          };
        in
          {nix = volume "/nix";}
          // mapToAttrs (p: nameValuePair (removePrefix "/" p) (volume p)) cfg.extraPools;
      };
    };
  };
}
