{ config, pkgs, lib, ... }:
let
  mediaDir = config.hostSpec.homelab.mediaDir;
in
{
  # Jellyseerr is a self-hosted media request management tool that integrates with Radarr and Sonarr
  services.seerr = {
    enable = true;
    openFirewall = false;  # Reverse proxy port 5055
  };

  # Radarr is a movie collection manager for Usenet and BitTorrent users, allowing you to automate the downloading of movies
  services.radarr = {
    enable = true;
    group = "media";
    user = "qbit";
    openFirewall = false; # Reverse proxy port 7878
  };

  # Sonarr is a PVR for Usenet and BitTorrent users, allowing you to automate the downloading of TV series
  services.sonarr = {
    enable = true;
    group = "media";
    user = "qbit";
    openFirewall = false;  # Reverse proxy port 8989
  };

  # Bazarr is a companion application for Sonarr and Radarr that manages subtitles
  services.bazarr = {
    enable = true;
    group = "media";
    user = "qbit";
    openFirewall = false; # Reverse proxy port 6767
  };

  # Lidarr is a music collection manager for Usenet and BitTorrent users, allowing you to automate the downloading of music
  services.lidarr = {
    enable = true;
    group = "media";
    user = "qbit";
    openFirewall = false;  # Reverse proxy port 8686
  };

  # Readarr is a book management tool similar to Radarr and Sonarr
  services.readarr = {
    enable = true;
    group = "media";
    user = "qbit";
    openFirewall = false;  # Reverse proxy port 8787
  };

  # Prowlarr is a replacement for Jackett, which is used to index torrent and usenet sites
  services.prowlarr = {
    enable = true;
    # group = "media";
    openFirewall = false;  # Reverse proxy port 9696
  };

  # oci container for feramance/qbitrr. 
  virtualisation.oci-containers.containers = {
    qbitrr = {
      image = "feramance/qbitrr:latest";
      autoStart = true;
      
      environment = {
        TZ = config.hostSpec.timezone;
      };

      ports = [
        "6969:6969"
      ];

      volumes = [
        "/var/lib/qbitrr:/config"
        "${mediaDir}/torrents:/completed_downloads:rw"
      ];
    };
  };
}
