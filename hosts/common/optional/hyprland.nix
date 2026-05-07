{ pkgs, lib, config, ... }:
{
  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    # nvidiaPatches = true;
    xwayland.enable = true;
  };
  hardware.graphics.enable = true;
}
