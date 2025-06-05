{ lib, config, pkgs, stylix, ... }:
let
  fancyTheme = import ./fancy.nix { inherit config; };
in
{
	programs.rofi = {
		enable = true;
    package = pkgs.rofi-wayland;
	};
	home.file.".config/rofi/themes/rounded-nord.rasi".source = ./rounded-nord.rasi; # symlink rofi theme
	home.file.".config/rofi/themes/rounded-common.rasi".source = ./rounded-common.rasi; # symlink rofi theme
	home.file.".config/rofi/config.rasi".source = ./config.rasi; # symlink rofi config
	home.file.".config/rofi/leave/leave.sh".source = ./leave.sh; # symlink rofi menu for leave button
	home.file.".config/rofi/themes/fancy.rasi".text = fancyTheme;
}
