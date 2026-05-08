{ pkgs, username, gitName, gitEmail, ... }: {
  home.username = username;
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    ripgrep
    fd
    bat
    eza
    fzf
  ];

  programs.git = {
    enable = true;
    userName = gitName;
    userEmail = gitEmail;
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
  };

  programs.starship = {
    enable = true;
    settings = builtins.fromTOML (builtins.readFile ./starship.toml);
  };
}
