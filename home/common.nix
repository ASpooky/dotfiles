{ pkgs, username, gitName, gitEmail, ... }: {
  home.username = username;
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    ripgrep
    fd
    bat
    eza
    fzf
    nodejs
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
    history = {
      size = 100000;
      save = 100000;
      share = true;
      ignoreDups = true;
      ignoreSpace = true;
      extended = true;
    };
    initContent = ''
      [ -f ~/.secrets ] && source ~/.secrets
    '';
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.starship = {
    enable = true;
    settings = builtins.fromTOML (builtins.readFile ./starship.toml);
  };
}
