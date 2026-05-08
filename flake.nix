{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      env = builtins.getEnv;
      username = env "USER";
      gitName = env "GIT_USER_NAME";
      gitEmail = env "GIT_USER_EMAIL";

      mkHome = system: modules:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = { inherit username gitName gitEmail; };
          modules = modules;
        };
    in {
      homeConfigurations = {
        # Linux / WSL2: `home-manager switch --impure --flake .#linux`
        linux = mkHome "x86_64-linux" [
          ./home/common.nix
          ./home/linux.nix
        ];
        # macOS (Apple Silicon): `home-manager switch --impure --flake .#darwin`
        darwin = mkHome "aarch64-darwin" [
          ./home/common.nix
          ./home/darwin.nix
        ];
        # macOS (Intel): `home-manager switch --impure --flake .#darwin-x86`
        darwin-x86 = mkHome "x86_64-darwin" [
          ./home/common.nix
          ./home/darwin.nix
        ];
      };
    };
}
