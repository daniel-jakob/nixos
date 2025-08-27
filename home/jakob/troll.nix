{ config, lib, pkgs, hostSpec, ... }:

{
  imports = [
    ../common/core
    ../common/optional/starship.nix
    ../common/optional/kitty.nix
    ];

  home = {
    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = hostSpec.stateVersion;
  };
}
