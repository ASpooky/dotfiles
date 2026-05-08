{ username, ... }: {
  home.homeDirectory = "/Users/${username}";

  targets.darwin.defaults = {
    NSGlobalDomain.AppleInterfaceStyle = "Dark";
  };
}
