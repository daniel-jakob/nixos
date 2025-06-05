{ config, lib, pkgs, ... }:
{
  imports = [
    ../../../modules/host-spec.nix
    ./host-spec-setter.nix
    ./fastfetch
    ./tmux.nix
    ./zsh.nix
    ./git.nix
    ./direnv.nix
    ./ssh.nix
    ./zoxide.nix
  ];

  programs = {
    home-manager.enable = true;
  };
}
