{ pkgs, ... }:
{
fonts.packages = [
    pkgs.nerd-fonts.fira-code
    pkgs.nerd-fonts.fira-mono
  ];
  # fonts.fontconfig.enable = true; # Enable fontconfig # needed?
}
