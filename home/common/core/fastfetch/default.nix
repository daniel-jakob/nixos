{ ... }:

{

  home.file.".config/fastfetch/config.jsonc".source = ./fastfetch/config.jsonc; # symlink fastfetch config.jsonc

  programs.fastfetch = {
    enable = true; # enable fastfetch
  };
}