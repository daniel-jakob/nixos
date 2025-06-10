# This is your home-manager configuration file
{ inputs
, lib
, config
, stylix
, pkgs
, ...
}:
{
  nixpkgs = {
    # You can add overlays here
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for ezample:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  stylix = {
    enable = true;
    image = ./village.jpg;
    base16Scheme = {
      base00 = "24273a"; # base
      base01 = "1e2030"; # mantle
      base02 = "363a4f"; # surface0
      base03 = "494d64"; # surface1
      base04 = "5b6078"; # surface2
      base05 = "cad3f5"; # text
      base06 = "f4dbd6"; # rosewater
      base07 = "b7bdf8"; # lavender
      base08 = "ed8796"; # red
      base09 = "f5a97f"; # peach
      base0A = "eed49f"; # yellow
      base0B = "a6da95"; # green
      base0C = "8bd5ca"; # teal
      base0D = "8aadf4"; # blue
      base0E = "c6a0f6"; # mauve
      base0F = "f0c6c6"; # flamingo
    };

    polarity = "dark";
  };

  home = {

    # Add stuff for your user as you see fit:
    packages = with pkgs; [
      (discord.override {
        # remove any overrides that you don't want
        withOpenASAR = true;
        # withVencord = true;
      })
      spotify-player
      swayidle
      swaylock-effects
      nil # NIX LSP
      nixpkgs-fmt
      playerctl
      nvd
      nix-output-monitor
      grim
      slurp
      jq
      swappy
    ];

    sessionVariables = {
      EDITOR = "nvim";
      SHELL = "zsh";
      GTK2_RC_FILES = lib.mkForce "$XDG_CONFIG_HOME/gtk-2.0/gtkrc"; # move gtk2 config to XDG_CONFIG_HOME
      XCURSOR_PATH = lib.mkForce "$XDG_DATA_HOME/icons";
      XCURSOR_SIZE = "20";
      XCOMPOSECACHE = "$XDG_CACHE_HOME/X11/xcompose"; # move .compose-cache of X11 to XDG_CACHE_HOME
    };
  };


  # Create XDG Dirs
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  programs = {

    bash = {
      enable = true;
      shellAliases = myAliases;
    };

    neovim = {
      enable = true;
    };

  };

  home.file.".config/swappy/config".text = ''
    [Default]
    save_dir=$HOME/Pictures/Screenshots
    save_filename_format=swappy-%Y%m%d-%H%M%S.png
    show_panel=false
    line_size=5
    text_size=20
    text_font=Ubuntu
    paint_mode=brush
    early_exit=true
    fill_shape=false
  '';

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

}
