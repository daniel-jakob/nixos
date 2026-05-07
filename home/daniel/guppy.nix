{ config, lib, pkgs, ... }:

{
  imports = [
    ../common/core
    ../common/optional/waybar
    ../common/optional/rofi
    ../common/optional/hyprland
    ../common/optional/starship.nix
    ../common/optional/swaync.nix
    ../common/optional/kitty.nix
    ../common/optional/cursor.nix
    ../../modules/monitors.nix # This is a custom module for monitor configuration
    ];

  # ========== Host-specific Monitor Spec ==========
  #
  # This uses the nix-config/modules/montiors.nix module.
  # Your nix-config/home-manger/<user>/common/optional/desktops/foo.nix WM config should parse and apply these values to it's monitor settings
  # If on hyprland, use `hyprctl monitors` to get monitor info.
  # https://wiki.hyprland.org/Configuring/Monitors/
  #   ______   
  #  |      |   ----------- 
  #  | DP-1 |  | HDMI-A-1 | 
  #  |      |  -----------
  #  -------   
  monitors = [
    {
      name = "HDMI-A-1";
      refreshRate = 120;
      workspace = "1";
      primary = true;
    }
    {
      name = "DP-1";
      height = 1200;
      x = -1920;
      refreshRate = 100;
      workspace = "8";
      transform = 1; # 90 degrees clockwise
    }
  ];
}
