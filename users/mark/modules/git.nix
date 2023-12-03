{
  config,
  network,
  user,
  ...
}: {
  programs.git = {
    enable = true;
    difftastic.enable = true;
    extraConfig = {
      user = {
        name = user;
        email = config.accounts.email.accounts.mark.address;
      };
    };
  };
}
