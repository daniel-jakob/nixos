# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/host-spec.nix
      ../common/core
      ../common/optional/audio.nix
      ../common/optional/printing.nix
      ../common/optional/sddm.nix
      ../common/optional/fonts.nix
      ../common/optional/wifi.nix
      ../common/optional/hyprland.nix
      ../common/optional/x11.nix
    ];

  hostSpec = import ./host-spec-attrs.nix;

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

  security.pam.services.swaylock = { }; # for swaylock unlocking purposes

  # Configure console keymap
  console.keyMap = "uk";

  programs = {
    zsh.enable = true;
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

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    systemPackages = with pkgs; [
      wget
      vscode
      libnotify
      base16-schemes
      git
      firefox
      swww # background wallpaper
      wl-clipboard
      home-manager
      libsForQt5.qt5.qtquickcontrols2 # for sddm theme
      libsForQt5.qt5.qtgraphicaleffects # for sddm theme
      lazygit
      docker
      lazydocker
    ];
    sessionVariables = {
      # If your cursor becomes invisible (only with nVidia)
      # WLR_NO_HARDWARE_CURSORS = "1";
      NIXOS_OZONE_WL = "1"; # Hint electron apps to use wayland
      MOZ_ENABLE_WAYLAND = "1"; # for Firefox to run on wayland
      MOZ_WEBRENDERER = "1"; # same as above
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

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  virtualisation.docker.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  networking.homelabWireguard = {
    enable = true;
    role = "client";
    interface = "wg0";
    vpnSubnet = "10.100.0.0/24";
    address = "10.100.0.2/32";
    privateKeyFile = "/etc/wireguard/guppy_private.key";
    # Alternative with sops-nix:
    # privateKeySopsKey = "wireguard_client_private_key";

    client = {
      endpoint = "REPLACE_WITH_YOUR_DDNS_OR_PUBLIC_IP:51820";
      serverPublicKey = "REPLACE_WITH_SERVER_PUBLIC_KEY";
      routeAllTraffic = false;
      splitTunnelCIDRs = [
        "192.168.0.0/24"
        "192.168.1.0/24"
      ];
      persistentKeepalive = 25;
    };
  };

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
