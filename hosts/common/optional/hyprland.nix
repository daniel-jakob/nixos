{ pkgs, lib, config, ... }:
{
  # Enable Hyprland
  prograns.hyprland = {
    enable = true;
    # nvidiaPatches = true;
    xwayland.enable = true;
  };
}