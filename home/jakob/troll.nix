{ config, lib, pkgs, hostSpec, ... }:

{
  imports = [
    ../common/core
    ../common/optional/starship.nix
    ../common/optional/kitty.nix
    ];
}
