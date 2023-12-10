{pkgs, ...}: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraLuaConfig = "require(\"config.lazy\")";
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withNodeJs = true;
    withPython3 = true;
    withRuby = true;
  };

  # _lua instead of lua so Telescope doesn't think ./lua is a project root.
  xdg.configFile."nvim/lua".source = ./_lua;

  home.packages =
    (with pkgs; [
      alejandra
      fd
      fzf
      lazygit
      lua-language-server
      nil
      nixd
      ripgrep
      rnix-lsp
      tree-sitter
      wl-clipboard
    ])
    ++ (with pkgs.vimPlugins.nvim-treesitter-parsers; [
      awk
      bash
      c
      cmake
      cpp
      css
      csv
      cuda
      diff
      dockerfile
      dot
      fish
      git_config
      git_rebase
      gitattributes
      gitcommit
      gitignore
      go
      gpg
      haskell
      html
      ini
      java
      javascript
      jq
      json
      lua
      luadoc
      make
      markdown
      markdown_inline
      nix
      python
      regex
      rust
      sql
      ssh_config
      starlark
      toml
      tsv
      typescript
      vim
      xml
      yaml
    ]);
}