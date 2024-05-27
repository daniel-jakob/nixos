# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{ inputs
, lib
, config
, pkgs
, ...
}:
let
  myAliases = {
    # Changing "ls" to "eza"
    ls = "eza --icons --color=always --group-directories-first";
    ll = "eza -alF --icons --color=always --group-directories-first";
    la = "eza -a --icons --color=always --group-directories-first";
    l = "eza -F --icons --color=always --group-directories-first";
    "l." = "eza -a | egrep '^\.' ";
    ".." = "cd ..";
  };
in
{
  # You can import other home-manager modules here
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModule

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
  ];

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

  home = {
    username = "daniel";
    homeDirectory = "/home/daniel";
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  home.packages = with pkgs; [
    discord
    fastfetch
    spotify-player
    swayidle
    swaylock-effects
    nil # NIX LSP
    nixpkgs-fmt
    bibata-cursors
    playerctl
    eza
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    SHELL = "zsh";
    GTK2_RC_FILES = lib.mkForce "$XDG_CONFIG_HOME/gtk-2.0/gtkrc"; # move gtk2 config to XDG_CONFIG_HOME
    XCURSOR_PATH = lib.mkForce "$XDG_DATA_HOME/icons";
    XCURSOR_SIZE = "20";
    ZDOTDIR = "$XDG_CONFIG_HOME/zsh"; # move zsh config to XDG_CONFIG_HOME
    XCOMPOSECACHE = "$XDG_CACHE_HOME/X11/xcompose"; # move .compose-cache of X11 to XDG_CACHE_HOME
  };

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    userName = "daniel";
    userEmail = "danieljakob1307@gmail.com";
  };

  programs.bash = {
    enable = true;
    shellAliases = myAliases;
  };

  programs.zsh = {
    enable = true;
    shellAliases = myAliases;
    enableCompletion = true;
    autosuggestion.enable = true;
    dotDir = ".config/zsh";
    syntaxHighlighting.enable = true;
    history = {
      path = "${config.xdg.dataHome}/zsh/history";
      save = 10000;
      size = 10000;
    };
    # Additional configuration for zinit and powerlevel10k
    plugins = [
      {
        name = "powerlevel10k-config";
        src = ./p10k;
        file = "p10k.zsh";
      }
      {
        name = "zsh-powerlevel10k";
        src = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/";
        file = "powerlevel10k.zsh-theme";
      }
    ];
    initExtra = ''
      # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
      # Initialization code that may require console input (password prompts, [y/n]
      # confirmations, etc.) must go above this block; everything else may go below.
      if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi
      # Completion files: Use XDG dirs
      [ -d "$XDG_CACHE_HOME"/zsh ] || mkdir -p "$XDG_CACHE_HOME"/zsh
      zstyle ':completion:*' cache-path "$XDG_CACHE_HOME"/zsh/zcompcache
      compinit -d "$XDG_CACHE_HOME"/zsh/zcompdump-$ZSH_VERSION
    '';
  };

  programs.kitty = {
    enable = true;
    theme = "Catppuccin-Mocha";
    shellIntegration.enableZshIntegration = true;
    font = {
      name = "FiraCode Nerd Font";
      size = 10;
    };
  };

  programs.firefox = {
    enable = true;
    /* ---- EXTENSIONS ---- */
    # Check about:support for extension/add-on ID strings.
    # Valid strings for installation_mode are "allowed", "blocked",
    # "force_installed" and "normal_installed".
    package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
      extraPolicies = {
        DisableTelemetry = true;
        ExtensionSettings = {
          "*".installation_mode = "allowed"; # blocks all addons except the ones specified below
          # uBlock Origin
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
          };
          # Cattpuccin Mocha Mauve theme
          "{76aabc99-c1a8-4c1e-832b-d4f2941d5a7a}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/catppuccin-mocha-mauve-git/latest.xpi";
            installation_mode = "force_installed";
          };
          # Return Youtube Dislike
          "{762f9885-5a13-4abd-9c77-433dcd38b8fd}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/return-youtube-dislikes/latest.xpi";
            installation_mode = "force_installed";
          };
          # Improve Youtube!
          "{3c6bf0cc-3ae2-42fb-9993-0d33104fdcaf}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/youtube-addon/latest.xpi";
            installation_mode = "force_installed";
          };
          # Old Reddit Redirect
          "{9063c2e9-e07c-4c2c-9646-cfe7ca8d0498}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/old-reddit-redirect/latest.xpi";
            installation_mode = "force_installed";
          };
          # Reddit Enhancement Suite
          "jid1-xUfzOsOFlzSOXg@jetpack" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/reddit-enhancement-suite/latest.xpi";
            installation_mode = "force_installed";
          };
        };
      };
    };
  };

  programs.neovim = {
    enable = true;
  };

  home.file.".config/hypr/hyprland.conf".source = ./hyprland/hyprland.conf; # symlink hyprland config
  home.file.".config/hypr/start.sh".source = ./hyprland/start.sh; # symlink hyprland zsh theme


  home.file.".config/rofi/themes/rounded-nord.rasi".source = ./rofi/rounded-nord.rasi; # symlink rofi theme
  home.file.".config/rofi/themes/rounded-common.rasi".source = ./rofi/rounded-common.rasi; # symlink rofi theme
  home.file.".config/rofi/config.rasi".source = ./rofi/config.rasi; # symlink rofi config

  home.file.".config/rofi/leave/leave.sh".source = ./rofi/leave.sh; # symlink rofi menu for leave button

  home.file.".config/waybar/config".source = ./waybar/config; # symlink waybar config
  home.file.".config/waybar/style.css".source = ./waybar/style.css; # symlink waybar config style.css

  home.pointerCursor = {
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 20;
    gtk.enable = true;
  };


  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
