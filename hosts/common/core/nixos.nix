# Core functionality for every nixos host
{ config, lib, pkgs, ... }:
{
  # Enable firmware with a license allowing redistribution
  hardware.enableRedistributableFirmware = true;

  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      warn-dirty = false;
      auto-optimise-store = true;
      use-xdg-base-directories = true;
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
