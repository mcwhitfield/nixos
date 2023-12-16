{...}: {
  programs.starship = {
    enable = true;
    settings = {
      format = builtins.concatStringsSep "" [
        "[ ](#a3aed2)"
        "[  ](bg:#a3aed2 fg:#090c0c)"
        "[](bg:#769ff0 fg:#a3aed2)"
        "$directory"
        "[](fg:#769ff0 bg:#394260)"
        "$git_branch"
        "$git_status"
        "[](fg:#394260 bg:#212736)"
        "$fill"
        "[](#769ff0)"
        "$nodejs"
        "$rust"
        "$golang"
        "$php"
        "$nix_shell"
        "[](fg:#a3aed2 bg:#769ff0)"
        "$time"
        "[ ](fg:#a3aed2)"
        "\n$character"
      ];
      directory = {
        style = "fg:#e3e5e5 bg:#769ff0";
        format = "[ $path ]($style)";
        truncation_length = 3;
        truncation_symbol = "…/";
      };
      directory.substitutions = {
        "documents" = "󰈙 ";
        "downloads" = " ";
        "music" = " ";
        "pictures" = " ";
        "public" = "";
      };
      fill = {
        symbol = "·";
        style = "fg:#707070 dimmed";
      };
      git_branch = {
        symbol = "";
        style = "bg:#394260";
        format = "[[ $symbol $branch ](fg:#769ff0 bg:#394260)]($style)";
      };
      git_status = {
        style = "bg:#394260";
        format = "[[($all_status$ahead_behind )](fg:#769ff0 bg:#394260)]($style)";
        ahead = "⇡\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        behind = "⇣\${count}";
      };
      nodejs = {
        symbol = "";
        style = "fg:#e3e5e5 bg:#769ff0";
        format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
      };
      rust = {
        symbol = "";
        style = "fg:#e3e5e5 bg:#769ff0";
        format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
      };
      golang = {
        symbol = "";
        style = "fg:#e3e5e5 bg:#769ff0";
        format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
      };
      nix_shell = {
        format = "[(❄️ $name \\($state\\)) ]($style)";
        symbol = "❄️";
        style = "fg:#e3e5e5 bg:#769ff0";
        heuristic = true;
      };
      php = {
        symbol = "";
        style = "fg:#e3e5e5 bg:#769ff0";
        format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
      };
      time = {
        disabled = false;
        time_format = "%R";
        style = "bg:#a3aed2";
        format = "[[  $time ](fg:#090c0c bg:#a3aed2)]($style)";
      };
    };
  };
}
