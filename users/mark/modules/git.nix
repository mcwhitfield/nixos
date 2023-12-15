{
  config,
  user,
  ...
}: {
  programs.git = {
    enable = true;
    difftastic.enable = true;
    extraConfig = {
      init.defaultBranch = "main";
      user = {
        name = user;
        email = config.accounts.email.accounts.mark.address;
      };
    };
  };
}
