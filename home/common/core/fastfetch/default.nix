{ ... }:

{

  home.file.".config/fastfetch/config.jsonc".source = ./config.jsonc; # symlink fastfetch config.jsonc

  programs.fastfetch = {
    enable = true; # enable fastfetch
  };
}