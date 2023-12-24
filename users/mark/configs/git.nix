{config, ...}: {
  programs.git = {
    enable = true;
    difftastic.enable = true;
    extraConfig = {
      init.defaultBranch = "main";
      user = {
        name = "Mark Whitfield";
        email = config.accounts.email.accounts.mark.address;
      };
    };
    signing = {
      signByDefault = true;
      key = null;
    };
  };
}
