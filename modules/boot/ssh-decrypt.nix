{
  self,
  config,
  domain,
  ...
}: let
  inherit (builtins) baseNameOf;
  inherit (self.lib) mkIf mkOption types;
  inherit (self.lib.attrsets) attrByPath mapToAttrs setAttrByPath;
  configKey = [domain "boot" "ssh-decrypt"];
  cfg = attrByPath configKey {} config;
in {
  options = setAttrByPath configKey {
    enable = mkOption {
      type = types.bool;
      default = !(config.${domain}.workstation.enable || config.boot.isContainer);
      description = ''
        Ship an SSH daemon in the initramfs to allow remote decryption of boot drives.
      '';
    };
    port = mkOption {
      type = types.port;
      default = 2222;
      description = ''
        Synonym of boot.initrd.network.ssh.port.

        The port that the boot-time SSH daemon will listen on. Should be something other than 22
        to avoid host-key confusion, since the boot-time daemon and normal run-time daemon Should
        use different keys.
      '';
    };
    command = mkOption {
      type = types.lines;
      default = ''
        zpool import -a
        echo "zfs load-key -a && killall zfs && exit" >> /root/.profile
      '';
      description = ''
        Synonym of boot.initrd.network.postCommands.

        A shell script to be executed when SSH connects. Should:
          - Perform the necessary operations to unlock encrypted drives
          - Signal the init process to continue somehow.

        The default value is functional for ZFS native-encrypted volumes; other approaches will need
        to change this.
      '';
    };
    hostKeys = mkOption {
      type = types.listOf types.str;
      default = let
        key = algo: "/etc/ssh/ssh-host-${config.networking.hostName}-initrd_${algo}";
      in [(key "rsa") (key "ed25519")];
      description = ''
        Synonym of boot.initrd.network.ssh.hostKeys with better defaults.

        Path to (pre-existing) SSH host keys on the target system. Must be unquoted strings,
        otherwise you'll run into issues with boot.initrd.secrets. The keys are copied to initrd
        from the path specified.
      '';
    };
    authorizedKeys = mkOption {
      type = types.listOf types.str;
      default = config.${domain}.admins.publicKeys.texts;
      description = ''
        Synonym of boot.initrd.network.ssh.authorizedKeys with better defaults.

        Authorized keys for the root user on initrd.
      '';
    };
  };

  config = mkIf (cfg.enable) {
    ${domain}.persist.files = cfg.hostKeys ++ (map (key: "${key}.pub") cfg.hostKeys);
    age.secrets = let
      mkSecret = path: {
        name = baseNameOf path;
        value = {
          path = path;
          file = self.secrets.${baseNameOf path};
          symlink = false;
        };
      };
    in
      mapToAttrs mkSecret cfg.hostKeys;
    boot.initrd = {
      # This is stage 1 boot so we don't have any fancy way to be sure the network interface is
      # ready yet, so just inject a small delay to reduce issues.
      preLVMCommands = "sleep 1";
      network = {
        enable = true;
        ssh = {
          # inherit (cfg) enable port hostKeys authorizedKeys;
        };
        postCommands = cfg.command;
      };
    };
  };
}
