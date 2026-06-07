# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:
let
  hostSpecAttrs = import ./host-spec-attrs.nix;
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/host-spec.nix
      ../common/core
      ../common/optional/fonts.nix
      ../common/optional/nixpkgs-insecure-pkgs.nix # (temp, hopefully) sonarr fix
    ]
    ++ lib.optionals (hostSpecAttrs.isHomelab or false) [
      ./homelab/jellyfin.nix
      ./homelab/immich.nix
      ./homelab/qbit.nix
      ./homelab/traefik.nix
      ./homelab/seer.nix
      ./homelab/paperless.nix
      ./homelab/blocky.nix
      ./homelab/mealie.nix
      ./homelab/forgejo.nix
      ./homelab/navidrome.nix
      ./homelab/vaultwarden.nix
      ./homelab/dawarich.nix
      ./homelab/obsidian-livesync.nix
      ./homelab/termix.nix
      ./homelab/minecraft.nix
    ];

  hostSpec = hostSpecAttrs;

  # Bootloader.
  boot.loader = {
    timeout = 0; # Set to 0 to skip the boot menu
    grub = { 
      enable = true;
      device = "/dev/sda";
      useOSProber = true;
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    ncurses
    comma
  ];

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
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = true;
      AllowUsers = null; # Allows all users by default. Can be [ "user1" "user2" ]
      UseDns = true;
      X11Forwarding = false;
      PermitRootLogin = "prohibit-password"; # "yes", "without-password", "prohibit-password", "forced-commands-only", "no"
    };
  };

  networking.homelabWireguard = {
    enable = true;
    role = "server";
    interface = "wg0";
    vpnSubnet = "10.100.0.0/24";
    address = "10.100.0.1/24";
    listenPort = 51820;
    privateKeySopsKey = "wireguard_server_private_key";

    server = {
      # This is the interface shown in your gusto hardware config comment.
      externalInterface = "enp0s31f6";
      peers = [
        # {
        #   # guppy
        #   publicKey = "REPLACE_WITH_GUPPY_PUBLIC_KEY";
        #   allowedIPs = [ "10.100.0.2/32" ];
        # }
        {
          # phone
          publicKey = "AYsoXHvJhhggl5petQKYPVE9tHsPiZeqWEHJA13yhVI=";
          allowedIPs = [ "10.100.0.3/32" ];
        }
        {
          # laptop
          publicKey = "8JHk2iT1dUVjVEP5s3iXi0a6bmlAkR8gm6RP2LBagGo=";
          allowedIPs = [ "10.100.0.4/32" ];
        }
      ];
    };
  };

  homelab.smtp = {
    enable = true;
    host = "smtp.postale.io";
    port = 465;
    from = config.hostSpec.email.personal;
    username = config.hostSpec.email.personal;
    passwordSopsKey = "smtp_password";
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
  system.stateVersion = config.hostSpec.stateVersion; # Did you read the comment?

}
