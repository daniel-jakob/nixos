{inputs, config, pkgs, lib, ... }:
{
  hostSpec.domain = lib.mkDefault "jakob.ie";

  imports = [
    ../../../modules/sops-host-defaults.nix
    ../../../modules/wireguard.nix
    ../../../modules/smtp.nix
    ./nixos.nix
    ./localisation.nix
    ./networking.nix
    ./user.nix
  ];
}
