{ pkgs, lib, config, ... }:
{
  programs.eza = {
    enable = true;
    icons = "auto";
    colors = "auto";
    # theme = "catppuccin";
    enableZshIntegration = true;
    extraOptions = [
      "--group-directories-first"
      "--no-quotes"
      "--git-ignore"
    ];
  };
}
