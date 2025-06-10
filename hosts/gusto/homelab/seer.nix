{ config, pkgs, lib, ... }:

{
  # Define the media group
  users.groups.media = {};

  # Jellyseerr is a self-hosted media request management tool that integrates with Radarr and Sonarr
  services.jellyseerr = {
    enable = true;
    openFirewall = true;  # Opens port 5055
  };

  # Radarr is a movie collection manager for Usenet and BitTorrent users, allowing you to automate the downloading of movies
  services.radarr = {
    enable = true;
    group = "media";
    openFirewall = true; # Opens port 7878
  };

  # Sonarr is a PVR for Usenet and BitTorrent users, allowing you to automate the downloading of TV series
  services.sonarr = {
    enable = true; # package is broken at the moment
    group = "media";
    openFirewall = true;  # Opens port 8989
  };

  # Bazarr is a companion application for Sonarr and Radarr that manages subtitles
  services.bazarr = {
    enable = true;
    group = "media";
    openFirewall = true; # Opens port 6767
  };

  # Lidarr is a music collection manager for Usenet and BitTorrent users, allowing you to automate the downloading of music
  services.lidarr = {
    enable = true;
    group = "media";
    openFirewall = true;  # Opens port 8686
  };

  # Readarr is a book management tool similar to Radarr and Sonarr
  services.readarr = {
    enable = true;
    group = "media";
    openFirewall = true;  # Opens port 8787
  };

  # Prowlarr is a replacement for Jackett, which is used to index torrent and usenet sites
  services.prowlarr = {
    enable = true;
    # group = "media";
    openFirewall = true;  # Opens port 9696
  };

  # # Jackett
  # services.jackett = {
  #   enable = true;
  #   group = "media";
  #   port = 9117;  # Default port
  # };

  # Open firewall ports
  networking.firewall.allowedTCPPorts = [ 5055 7878 8989 9117 ];
}