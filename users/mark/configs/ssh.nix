{...}: {
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    forwardAgent = true;
    matchBlocks = {
      "git.github.com" = {
        hostname = "github.com";
        user = "git";
      };
    };
  };
}
