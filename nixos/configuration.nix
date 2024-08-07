# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        devices = [ "nodev" ];
        efiSupport = true;
        useOSProber = true;
      };
    };
    kernelPackages = pkgs.linuxPackages_latest; # Use the latest kernel.
    supportedFilesystems = [ "ntfs" ];
  };
  fileSystems."/mnt/FireCuda" = {
    device = "/dev/disk/by-uuid/CAFA34CCFA34B713";
    fsType = "ntfs";
    options = [ "rw" ];
  };
  fileSystems."/mnt/BarraCuda" = {
    device = "/dev/disk/by-uuid/B0EC3EB1EC3E71A8";
    fsType = "ntfs";
    options = [ "rw" ];
  };

  networking = {
    hostName = "nixos"; # Define your hostname.
    networkmanager.enable = true; # Enable networking#
    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ]; # enable flakes
    auto-optimise-store = true; # auto optimse nix store with links to single instances of dependencies
  };

  # Set your time zone.
  time = {
    timeZone = "Europe/Dublin";
    hardwareClockInLocalTime = true;
  };

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_GB.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_IE.UTF-8";
      LC_IDENTIFICATION = "en_IE.UTF-8";
      LC_MEASUREMENT = "en_IE.UTF-8";
      LC_MONETARY = "en_IE.UTF-8";
      LC_NAME = "en_IE.UTF-8";
      LC_NUMERIC = "en_IE.UTF-8";
      LC_PAPER = "en_IE.UTF-8";
      LC_TELEPHONE = "en_IE.UTF-8";
      LC_TIME = "en_IE.UTF-8";
    };
  };

  security.pam.services.swaylock = { }; # for swaylock unlocking purposes

  # Enable the X11 windowing system.
  services = {
    xserver = {
      enable = true;
      # Configure keymap in X11
      xkb.layout = "gb";
      xkb.variant = "";
      # Remove XTerm 
      excludePackages = [ pkgs.xterm ];
    };
    printing.enable = true; # Enable CUPS to print documents.
    displayManager.sddm = {
      enable = true; #This line enables sddm
      theme = "${import ./sddm-theme.nix { inherit pkgs; }}";
    };
  };

  # Configure console keymap
  console.keyMap = "uk";

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true; # Write wireplumber configuration for no auto suspend
    wireplumber.configPackages = [
      (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/alsa.conf" ''
        monitor.alsa.rules = [ 
          {
            matches = [
              {
                device.name = "~alsa_card.*"
              }
            ]
            actions = {
              update-props = {
                # Device settings
                api.alsa.use-acp = true
              }
            }
          }
          {
            matches = [
              {
                node.name = "~alsa_input.*"
              }
              {
                node.name = "~alsa_output.*"
              }
            ]
            actions = {
            # Node settings
              update-props = {
                session.suspend-timeout-seconds = 0
              }
            }
          }
        ]
      '')
    ];
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.daniel = {
    isNormalUser = true;
    description = "Daniel";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      #  thunderbird
    ];
    shell = pkgs.zsh;
  };

  # Enabling hyprlnd on NixOS
  programs = {
    hyprland = {
      enable = true;
      # nvidiaPatches = true;
      xwayland.enable = true;
    };
    zsh.enable = true;

    nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 3";
      flake = "/home/daniel/mysystem";
    };

  };

  #XDG portal
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland
    ];
  };

  hardware = {
    opengl.enable = true; # OpenGL

    # Most wayland compositors need this
    # nvidia.modesetting.enable = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    systemPackages = with pkgs; [
      wget
      kitty # terminal
      rofi-wayland # app launcher
      waybar # status bar
      swaynotificationcenter # notification daemon
      vscode
      libnotify
      base16-schemes
      git
      firefox
      swww # background wallpaper
      zsh # shell
      wl-clipboard
      home-manager
      libsForQt5.qt5.qtquickcontrols2 # for sddm theme
      libsForQt5.qt5.qtgraphicaleffects # for sddm theme
    ];
    sessionVariables = {
      # If your cursor becomes invisible (only with nVidia)
      # WLR_NO_HARDWARE_CURSORS = "1";
      NIXOS_OZONE_WL = "1"; # Hint electron apps to use wayland
      MOZ_ENABLE_WAYLAND = "1"; # for Firefox to run on wayland
      MOZ_WEBRENDERER = "1"; # same as above
      # XDG Base Directory Defaults
      XDG_CACHE_HOME = "$HOME/.cache";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_STATE_HOME = "$HOME/.local/state";
      ZDOTDIR = "$XDG_CONFIG_HOME/zsh"; # move zsh config to XDG_CONFIG_HOME
    };
  };

  # stylix = {
  #   enable = true;
  #   image = "$HOME/Pictures/village.jpg";
  #   base16Scheme = "${pkgs.base16-schemes}/share/themes/mocha.yaml";

  #   cursor.package = pkgs.bibata-cursors;
  #   cursor.name = "Bibata-Modern-Ice";

  #   polarity = "dark";
  # };


  fonts.packages = with pkgs; [ (nerdfonts.override { fonts = [ "FiraCode" ]; }) ];


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
