{ config, lib, pkgs, ... }:

{
  imports = [    
    ../common/optional/waybar
    ../common/optional/rofi
    ../common/optional/hyprland
    ../common/optional/starship.nix
    ../common/optional/swaync.nix
    ../common/optional/kitty.nix
    ];

  home = {
    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "24.05";
  };
}