{
  self,
  pkgs,
  osConfig,
  domain,
  ...
}: {
  config = self.lib.mkIf (osConfig.${domain}.workstation.enable) {
    home.packages = with pkgs; [
      lutris-free
      wine
    ];
  };
}
