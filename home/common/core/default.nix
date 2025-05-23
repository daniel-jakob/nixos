{ config, lib, pkgs, ... }:

{
  imports = [
    ./fastfetch/
    ./tmux/
  ];
}