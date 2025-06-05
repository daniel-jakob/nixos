{ ... }:
let
  waybarSettings = import ./waybar-config.nix { inherit config; };
in
{
  # enable waybar and set config
  programs.waybar = {
    enable = true;
    settings = waybarSettings;
    
  # symlink waybar style
  home.file.".config/waybar/style.css".source = ./waybar/style.css; # symlink waybar config style.css
}