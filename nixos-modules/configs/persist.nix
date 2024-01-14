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
      ${domain}.disko.extraPools = [persistDir];
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
          files = let
            machineId =
              if config.boot.isContainer
              then []
              else ["/etc/machine-id"];
            hostKeys = [
              "/etc/ssh/ssh_host_ed25519_key"
              "/etc/ssh/ssh_host_ed25519_key.pub"
              "/etc/ssh/ssh_host_rsa_key"
              "/etc/ssh/ssh_host_rsa_key.pub"
            ];
          in
            machineId
            ++ hostKeys
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
    };
}
