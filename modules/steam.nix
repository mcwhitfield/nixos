{
  self,
  config,
  pkgs,
  domain,
  ...
}: let
  inherit (self.lib) getName mkIf mkOption types;
  inherit (self.lib.attrsets) attrByPath setAttrByPath;
  configKey = [domain "steam"];
  cfg = attrByPath configKey {} config;
in {
  options = setAttrByPath configKey {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable Steam installation on the system.
      '';
    };
  };

  config = mkIf (cfg.enable) {
    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;
    };
    environment.systemPackages = with pkgs; [
      gamemode
      gst_all_1.gstreamer
      # Common plugins like "filesrc" to combine within e.g. gst-launch
      gst_all_1.gst-plugins-base
      # Specialized plugins separated by quality
      gst_all_1.gst-plugins-good
      gst_all_1.gst-plugins-bad
      gst_all_1.gst-plugins-ugly
      # Plugins to reuse ffmpeg to play almost every video format
      gst_all_1.gst-libav
      # Support the Video Audio (Hardware) Acceleration API
      gst_all_1.gst-vaapi
      vulkan-tools
    ];
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (getName pkg) [
        "steam"
        "steam-original"
        "steam-run"
      ];
  };
}
