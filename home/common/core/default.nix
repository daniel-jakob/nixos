{ config, lib, pkgs, ... }:

{
  imports = [
    ./fastfetch
    ./tmux.nix
    ./zsh.nix
  ];
}