# dotfiles

Home Manager configuration for Linux, macOS, and WSL2.

## Prerequisites

Install Nix: https://zero-to-nix.com/start/install/

## Usage

Set environment variables, then run with `--impure`:

```sh
export GIT_USER_NAME="Your Name"
export GIT_USER_EMAIL="your@email.com"

# Linux / WSL2  (USER is set automatically)
home-manager switch --impure --flake .#linux

# macOS (Apple Silicon)
home-manager switch --impure --flake .#darwin

# macOS (Intel)
home-manager switch --impure --flake .#darwin-x86
```

`USER` is read from the shell environment automatically on Linux and macOS.

## Setup

Add `starship.toml` if you use Starship (or remove that block from `home/common.nix`).
