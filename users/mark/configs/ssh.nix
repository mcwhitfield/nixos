{...}: {
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "git.github.com" = {
        hostname = "github.com";
        user = "git";
      };
    };
  };
}
