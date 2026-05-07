{ config, pkgs, lib, ... }:
{  
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    # flake = config.hostSpec.flakeLocation;
    flake = "/home/${config.hostSpec.username}/mysystem";
  };
}
