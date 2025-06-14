{ config, pkgs, ... }:
let
  mediaDir = "/media"; # TODO: make a config.hostSpec field for isHomelab.mediaDir
in
# https://github.com/zmitchell/nixos-configs/blob/main/modules/media_server.nix
{
  # Enable OCI container support
  virtualisation.oci-containers.containers = {

    gluetun = {
      image = "ghcr.io/qdm12/gluetun";
      environment = {
        VPN_SERVICE_PROVIDER = "surfshark";
        VPN_TYPE = "openvpn"; # or wireguard
        OPENVPN_USER = "BdVgKj5FWZSLSWduj6kMcnbv";
        OPENVPN_PASSWORD = "x8JLMSL54UetNHfbTjm9hNLh";
        TZ = "Europe/Berlin";
        SERVER_COUNTRIES = "Germany"; # or a comma-separated list
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
        "${mediaDir}/torrents:${mediaDir}/torrents"
        "${mediaDir}/torrents/.incomplete:${mediaDir}/torrents/.incomplete"
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