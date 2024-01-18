{
  self,
  options,
  config,
  domain,
  impermanence,
  ...
}: let
  inherit (self.lib) mkIf mkOption types;
  inherit (self.lib.attrsets) attrByPath filterAttrs genAttrs mapAttrsToList setAttrByPath;
  configKey = [domain "persist"];

  cfg = attrByPath configKey {} config;
  opts = attrByPath configKey {} options;
in {
  imports = [
    impermanence.nixosModules.impermanence
  ];

  options = setAttrByPath configKey {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Enable Impermanence integration on this host. Surfaces options for configuring the required
        filesystem layout, as well as ensuring persistence of a few key pieces of state necessary for
        smooth system operation:

          * NixOS config
          * System logs
          * Network and bluetooth connection profiles.
          * SSH config
          * Auto-generated machine ID
      '';
    };
    directories = mkOption {
      type = types.listOf (types.strMatching "/.*");
      default = [
        "/var/log"
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
        "/etc/nixos"
      ];
      description = ''
        Extra directories to be persisted on hosts which have Impermanence enabled.
      '';
    };
    files = mkOption {
      type = types.listOf (types.strMatching "/.*");
      description = ''
        Extra files to be persisted on hosts which have Impermanence enabled.
      '';
      default = let
        machine-id =
          if config.boot.isContainer
          then []
          else ["/etc/machine-id"];
        keys = map (k: k.path) cfg.hostKeys;
        pubKeys = map (k: "${k}.pub") keys;
      in
        machine-id ++ keys ++ pubKeys;
    };
    hostKeys = mkOption {
      type = types.listOf types.attrs;
      default = [
        {
          type = "ed25519";
          path = "/etc/ssh/ssh_host_ed25519_key";
        }
        {
          type = "rsa";
          bits = 4096;
          path = "/etc/ssh/ssh_host_rsa_key";
        }
      ];
      description = ''
        Alias of services.openssh.hostKeys.

        SSH host keys for the current system. Impermanence needs to ensure these keys are
        available early at boot time so secrets can be mounted properly.
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
      users = mkOption {
        type = types.str;
        default = "${cfg.mounts.root}/home";
        description = ''
          The subdirectory within `mounts.root` at which the persistent data for this system's users
          is rooted.
        '';
      };
      containers = mkOption {
        type = types.str;
        default = "${cfg.mounts.root}/containers";
        description = ''
          The subdirectory within `mounts.root` at which the persistent data for this system's
          hosted containers is rooted.
        '';
      };
      system = mkOption {
        type = types.str;
        default = "${cfg.mounts.root}/hosts/${config.networking.hostName}";
        description = ''
          The subdirectory within `mounts.root` at which the persistent data for this system is
          rooted.
        '';
      };
    };
  };

  config = let
    roots = subdir: mapAttrsToList (name: _: "${subdir}/${name}");
    enabledUsers = filterAttrs (_: cfg': cfg'.enable) config.${domain}.users;

    userRoots = roots cfg.mounts.users enabledUsers;
    containerRoots = roots cfg.mounts.containers config.${domain}.containers;

    systemConf = {${cfg.mounts.system}.neededForBoot = true;};
    userConfs = genAttrs userRoots (_: {
      neededForBoot = true;
      options = ["X-mount.mode=777"];
    });
    containerConfs = genAttrs containerRoots (_: {neededForBoot = true;});
  in
    mkIf (cfg.enable) {
      ${domain} = {
        disko.extraPools = [cfg.mounts.system];
        persist.directories = opts.directories.default;
        persist.files = opts.files.default;
      };

      environment.persistence.${cfg.mounts.system} = {
        inherit (cfg) directories files;
      };

      fileSystems = systemConf // userConfs // containerConfs;

      # https://github.com/nix-community/impermanence/issues/101
      services.openssh = {inherit (cfg) hostKeys;};
      # Ensure /persist mounts with required ssh keys available.
      systemd.services.agenix.after = ["basic.target"];
    };
}
