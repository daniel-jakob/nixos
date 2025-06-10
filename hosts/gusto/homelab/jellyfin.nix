{ config, pkgs, lib, ... }:
let 
  mediaDir = "/media"; # TODO: make a config.hostSpec field for isHomelab.mediaDir
in
{
  imports = [
    ../../../modules/intel-hardware-accel.nix
  ];

  services.jellyfin = {
    enable = true;
    user = "jellyfin";
    group = "jellyfin";
    
    # Bind to internal network only
    openFirewall = true;  # Opens port 8096
    
    # Optional: Hardware acceleration for Intel GPUs
    package = pkgs.jellyfin;
  };

  # Optional: Define media directories
  systemd.services.jellyfin.serviceConfig = {
    # Add any custom directories jellyfin needs access to
    SupplementaryGroups = [ "media" ];  # If you have a media group
  };

  # Create media group if you want to manage media access
  users.groups.media = {};

  # Create the directories that the services will need with the correct permissions
  # TODO: make a config.hostSpec field for isHomelab.mediaDir
  systemd.tmpfiles.rules = [
    "d ${mediaDir} 0775 root media -"
    "d ${mediaDir}/movies 0775 root media -"
    "d ${mediaDir}/tv 0775 root media -"
    "d ${mediaDir}/audiobooks 0775 root media -"
  ];
  hardware.intelAcceleration = {
    enable = true;
    users = [ "jellyfin" ];
  };
}