{ config, pkgs, ... }:
let
  domain = config.hostSpec.domain;
  devices = config.hostSpec.homelab.network.devices;
in

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
  #   networking.firewall.allowedTCPPorts = [ 2283 ];

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

  # Immich public proxy 
  # virtualisation.oci-containers.containers = {
  #   immich-public-proxy = {
  #     image = "alangrainger/immich-public-proxy:latest";
  #     ports = [ "3000:3000" ];
  #     environment = {
  #       PUBLIC_BASE_URL = "https://photos.${domain}";
  #       IMMICH_URL = "https://photos.${domain}";
  #     };
  #   };
  # };
  services.immich-public-proxy = {
    enable = true;
    port = 2284;
    immichUrl = "http://localhost:2283";
    settings = {
      downloadOriginalPhoto = true;
      showGalleryTitle = true;
      showGalleryDescription = true;
      allowDownloadAll = 1;
      allowSlugLinks = true; # enables custom short links /s/abc123
    };
  };
}
