{ config, lib, pkgs, ... }:

{
  imports = [    
    ../common/optional/starship.nix
    ];

  home = {
    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = config.hostSpec.stateVersion;
  };
}