{ config, pkgs, ... }:

{
  imports = [
    ../../../modules/intel-hardware-accel.nix
  ];

  services.immich = {
    enable = true;
    mediaLocation = "/var/lib/immich";
    # You can set this to your preferred user/group
    user = "immich";
    group = "immich";

    # Database settings (uses built-in postgresql by default)
    database = {
      enable = true;
    };

    # Immich server settings
    host = "0.0.0.0";
    port = 2283;
  };

  # Open the Immich port in the firewall (if not using a reverse proxy)
  networking.firewall.allowedTCPPorts = [ 2283 ];

  # Create the data directory and user/group
  users.users.immich = {
    isSystemUser = true;
    group = "immich";
    home = "/var/lib/immich";
    createHome = true;
  };

  hardware.intelAcceleration = {
    enable = true;
    users = [ "immich" ];
  };
  # services.immich.accelerationDevices = null;

}