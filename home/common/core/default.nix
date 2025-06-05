{ config, lib, pkgs, ... }:

{
  imports = [
    ./fastfetch
    ./tmux.nix
    ./zsh.nix
    ./git.nix
    ./direnv.nix
    ./ssh.nix
    ./git.nix
  ];

  programs = {
    home-manager.enable = true;
  };
}