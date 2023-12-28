{
  self,
  config,
  options,
  domain,
  impermanence,
  ...
}: let
  inherit (self.lib) mkEnableOption mkIf mkOption types;
  inherit (self.lib.attrsets) attrByPath selfAndAncestorsEnabled setAttrByPath;
  configKey = [domain "persist"];

  cfg = attrByPath configKey {} config;
in {
  imports = [
    impermanence.nixosModules.impermanence
  ];

  options = setAttrByPath configKey {
    enable = mkEnableOption ''
      Enable Impermanence integration on this host. Surfaces options for configuring the required
      filesystem layout, as well as ensuring persistence of a few key pieces of state necessary for
      smooth system operation:

        * NixOS config
        * System logs
        * Network and bluetooth connection profiles.
        * SSH config
        * Auto-generated machine ID
    '';
    tmpfs = {
      root.maxSize = mkOption {
        type = types.str;
        default = "2G";
        description = ''
          Size of the tmpfs that will be mounted at `/`, i.e. the
          max system memory sacrificed for storage of non-persistent system files.
        '';
      };
      home.maxSize = mkOption {
        type = types.str;
        default = "2G";
        description = ''
          Size of the tmpfs that will be mounted at `/home`, i.e. the
          max system memory sacrificed for storage of non-persistent user files.
        '';
      };
    };
    directories = mkOption {
      type = types.listOf (types.strMatching "/.*");
      default = [];
      description = ''
        Extra directories to be persisted on hosts which have Impermanence enabled.
      '';
    };
    files = mkOption {
      type = types.listOf (types.strMatching "/.*");
      default = [];
      description = ''
        Extra files to be persisted on hosts which have Impermanence enabled.
      '';
    };
    fileSystems = let
      filesystemOption = desc:
        mkOption {
          type = options.fileSystems.type.nestedTypes.elemType;
          description = desc;
        };
    in {
      boot = filesystemOption ''
        The volume partition to be used for /boot.
      '';
      nix = filesystemOption ''
        The volume partition to be used for /nix.
      '';
      persistent = {
        root = filesystemOption ''
          The volume partition to be used for persistent directories/files under `/`.
        '';
        home = filesystemOption ''
          The volume partition to be used for persistent directories/files under `/home`.
        '';
      };
    };
    mounts = {
      root = mkOption {
        type = types.strMatching "/.*";
        default = "/persist";
        description = ''
          The absolute path at which `fileSystems.root` will be mounted. Should be chosen to avoid
          conflicts with the root filesystem, but otherwise can be any value.
        '';
      };
      home = mkOption {
        type = types.strMatching "/.*";
        default = "/persist/home";
        description = ''
          The absolute path at which `fileSystems.persistent.home` will be mounted. Should be
          chosen to avoid conflicts with the root filesystem, but otherwise can be any value.
        '';
      };
    };
  };

  config = mkIf (selfAndAncestorsEnabled configKey config) {
    environment = {
      persistence.${cfg.mounts.root} = {
        directories =
          [
            "/var/log"
            "/var/lib/bluetooth"
            "/var/lib/nixos"
            "/var/lib/systemd/coredump"
            "/etc/NetworkManager/system-connections"
            "/etc/nixos"
            "/etc/ssh"
          ]
          ++ cfg.directories;
        files =
          [
            "/etc/machine-id"
          ]
          ++ cfg.files;
      };
    };
    fileSystems = {
      "/" = {
        device = "none";
        fsType = "tmpfs";
        options = ["defaults" "size=${cfg.tmpfs.root.maxSize}" "mode=755"];
      };
      "/home" = {
        device = "none";
        fsType = "tmpfs";
        options = ["defaults" "size=${cfg.tmpfs.home.maxSize}" "mode=755"];
      };
      "/boot" = cfg.fileSystems.boot;
      "/nix" = cfg.fileSystems.nix;
      ${cfg.mounts.root} = cfg.fileSystems.persistent.root // {neededForBoot = true;};
      ${cfg.mounts.home} = cfg.fileSystems.persistent.home // {neededForBoot = true;};
      "/etc/ssh" = {
        device = "${cfg.mounts.root}/etc/ssh";
        neededForBoot = true;
        options = ["bind"];
      };
    };
  };
}
