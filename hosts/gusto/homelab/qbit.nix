{ config, pkgs, ... }:
let
  mediaDir = "/media"; # TODO: make a config.hostSpec field for isHomelab.mediaDir
in
# https://github.com/zmitchell/nixos-configs/blob/main/modules/media_server.nix
{
  # Enable OCI container support
  virtualisation.oci-containers.containers = {

    gluetun = {
      image = "qdm12/gluetun";
      environment = {
        VPN_SERVICE_PROVIDER = "surfshark";
        VPN_TYPE = "wireguard"; # or openvpn
        WIREGUARD_PRIVATE_KEY = "YOUR_WIREGUARD_PRIVATE_KEY"; # or OPENVPN_USER and OPENVPN_PASSWORD
        SERVER_COUNTRIES = "us"; # or a comma-separated list
        DNS_ADDRESS = "1.1.1.1";
        FIREWALL_VPN_INPUT_PORTS = "6881"; # Torrent port
      };
      ports = [ "6881:6881" "6881:6881/udp" "8080:8080" ];
      extraOptions = [
        "--cap-add=NET_ADMIN"
        "--device=/dev/net/tun:/dev/net/tun"
      ];
      volumes = [ "gluetun:/config" ];
    };

    qbittorrent = {
      image = "lscr.io/linuxserver/qbittorrent:latest";
      environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = "Europe/Berlin";
        WEBUI_PORT = "8080";
      };
      volumes = [
        "/var/lib/qbittorrent/config:/config"
        "${mediaDir}/torrents:/downloads"
      ];
      # Use extraOptions to pass the --network flag directly to Podman
      extraOptions = [
        "--network=container:gluetun"
      ];
      dependsOn = [ "gluetun" ];
    };
  };

  # Open required ports in firewall
  networking.firewall = {
    allowedTCPPorts = [ 6881 8080 ];
    allowedUDPPorts = [ 6881 ];
  };

  # TODO: hostSpec option for media directory
  # Create directories with correct permissions
  systemd.tmpfiles.rules = [
    "d /var/lib/qbittorrent/config 0755 root media -"

    # These are the actual directories on the host that qBittorrent will use via the mount
    "d ${mediaDir}/torrents 0775 root media -"
    "d ${mediaDir}/torrents/.incomplete 0775 root media -"
    "d ${mediaDir}/torrents/.watch 0775 root media -"
    "d ${mediaDir}/torrents/radarr 0775 root media -"
    "d ${mediaDir}/torrents/sonarr 0775 root media -"
    "d ${mediaDir}/torrents/bazarr 0775 root media -"
  ];
}