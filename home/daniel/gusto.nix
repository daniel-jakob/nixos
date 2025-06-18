{ config, lib, pkgs, ... }:

{
  imports = [    
    ../common/core
    ../common/optional/starship.nix
    ../common/optional/eza.nix
    ];

  home = {
    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = config.hostSpec.stateVersion;
  };
}