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
      maxSize = mkOption {
        type = types.str;
        default = "6G";
        description = ''
          Size of the tmpfs that will be mounted at `/`, i.e. the
          max system memory sacrificed for storage of non-persistent system files.
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
    manageFileSystems = mkOption {
      type = types.bool;
      default = !config.boot.isContainer;
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
          The absolute path at which `fileSystems.root` is mounted on the host filesystem. Should be
          chosen to avoid conflicts with the root filesystem, but otherwise can be any value.
        '';
      };
      system = mkOption {
        type = types.strMatching "/.*";
        default = "/hosts/${config.networking.hostName}";
        description = ''
          The subdirectory within `mounts.root` at which the persistent data for this system is rooted.
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

  config = let
    persistDir = "${cfg.mounts.root}${cfg.mounts.system}";
  in
    mkIf (selfAndAncestorsEnabled configKey config) {
      environment = {
        persistence.${persistDir} = {
          directories =
            [
              "/var/log"
              "/var/lib/bluetooth"
              "/var/lib/nixos"
              "/var/lib/systemd/coredump"
              "/etc/NetworkManager/system-connections"
              "/etc/nixos"
            ]
            ++ cfg.directories;
          files =
            [
              "/etc/machine-id"
              "/etc/ssh/ssh_host_ed25519_key"
              "/etc/ssh/ssh_host_ed25519_key.pub"
              "/etc/ssh/ssh_host_rsa_key"
              "/etc/ssh/ssh_host_rsa_key.pub"
            ]
            ++ cfg.files;
        };
      };
      # https://github.com/nix-community/impermanence/issues/101
      services.openssh.hostKeys = [
        {
          type = "ed25519";
          path = "${persistDir}/etc/ssh/ssh_host_ed25519_key";
        }
        {
          type = "rsa";
          bits = 4096;
          path = "${persistDir}/etc/ssh/ssh_host_rsa_key";
        }
      ];
      fileSystems = mkIf (cfg.manageFileSystems) {
        "/" = {
          device = "none";
          fsType = "tmpfs";
          options = ["defaults" "size=${cfg.tmpfs.maxSize}" "mode=755"];
        };
        ${cfg.mounts.root} =
          cfg.fileSystems.persistent.root
          // {
            neededForBoot = true;
            mountPoint = cfg.mounts.root;
          };
        ${cfg.mounts.home} =
          cfg.fileSystems.persistent.home
          // {
            neededForBoot = true;
            mountPoint = cfg.mounts.home;
          };
        "/boot" = cfg.fileSystems.boot // {mountPoint = "/boot";};
        "/nix" = cfg.fileSystems.nix // {mountPoint = "/nix";};
      };
    };
}
