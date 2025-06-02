{ config, lib, pkgs, ... }:

{
  imports = [    
    ../common/optional/starship.nix
    ];

  home = {
    stateVersion = "23.11";
  };
}