{inputs, config, pkgs, lib, ... }:
{
  imports = [
    ./nixos.nix
    ./localisation.nix
    ./networking.nix
  ];
}