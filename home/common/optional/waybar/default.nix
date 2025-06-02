{ ... }:
{
  # enable waybar
  programs.waybar.enable = true;
  # symlink waybar config
  home.file.".config/waybar/config".source = ./waybar/config; # symlink waybar config
  home.file.".config/waybar/style.css".source = ./waybar/style.css; # symlink waybar config style.css
}