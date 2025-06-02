{ pkgs, lib, config, ... }:
{
  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    # Configure keymap in X11
    xkb.layout = "gb";
    xkb.variant = "";
    # Remove XTerm 
    excludePackages = [ pkgs.xterm ];
  };
}