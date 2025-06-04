{ config, lib, pkgs, ... }:

{
  imports = [
    ./fastfetch
    ./tmux.nix
    ./zsh.nix
  ];

  programs = {
    home-manager.enable = true;
  };
}