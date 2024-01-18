{
  self,
  config,
  pkgs,
  domain,
  caps2superesc,
  ...
}: let
  inherit (self.lib) getExe' mkEnableOption mkIf;
  inherit (self.lib.attrsets) selfAndAncestorsEnabled setAttrByPath;
  configKey = [domain "caps2superesc"];
in {
  options = setAttrByPath configKey {
    enable = mkEnableOption ''
      Enable https://wiki.archlinux.org/title/Interception-tools, configured to replace the Caps
      Lock key with Esc (hen pressed) or Super/Windows key (when held).
    '';
  };

  config = mkIf (selfAndAncestorsEnabled configKey config) {
    nixpkgs.overlays = [caps2superesc.overlays.default];
    services = {
      interception-tools.enable = true;
      # Some weird-ass bug where the final systemd unit overrides its own PATH in ExecStart?
      # Can't figure out where that's coming from, it's not part of ExecStart in the Nix config.
      interception-tools.udevmonConfig = let
        intercept = getExe' pkgs.interception-tools "intercept";
        uinput = getExe' pkgs.interception-tools "uinput";
        caps2superesc = getExe' pkgs.caps2superesc "caps2superesc";
      in ''
        - JOB: "${intercept} -g $DEVNODE | ${caps2superesc} -m 1 -t 100 | ${uinput} -d $DEVNODE"
          DEVICE:
            EVENTS:
              EV_KEY: [KEY_CAPSLOCK, KEY_ESC]
      '';
    };
  };
}