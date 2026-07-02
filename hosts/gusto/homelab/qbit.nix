{ config, pkgs, ... }:
let
  mediaDir = config.hostSpec.homelab.mediaDir;
in
{
  sops.secrets.vpn_user = {
    restartUnits = [ "podman-gluetun.service" ];
  };

  sops.secrets.vpn_pass = {
    restartUnits = [ "podman-gluetun.service" ];
  };

  sops.templates.vpn_env = {
    owner = "root";
    group = "root";
    mode = "0400";
    content = ''
      OPENVPN_USER=${config.sops.placeholder.vpn_user}
      OPENVPN_PASSWORD=${config.sops.placeholder.vpn_pass}
    '';
  };

  # Enable OCI container support
  virtualisation.oci-containers.containers = {
    gluetun = {
      image = "docker.io/qmcgaw/gluetun:v3.40";
      environmentFiles = [
        config.sops.templates.vpn_env.path
      ];
      environment = {
        VPN_SERVICE_PROVIDER = "surfshark";
        VPN_TYPE = "openvpn"; # or wireguard
        TZ = config.hostSpec.timezone;
        SERVER_COUNTRIES = "Germany"; # or a comma-separated list
        DNS_ADDRESS = "162.252.172.57";
        FIREWALL_VPN_INPUT_PORTS = "6881"; # Torrent port
      };
      ports = [ 
        "6881:6881"
        "6881:6881/udp"
        "127.0.0.1:8080:8080" # qBit WebUI reachable only locally (for Traefik)
        "127.0.0.1:8888:8888"
      ];
      extraOptions = [
        "--cap-add=NET_ADMIN"
        "--device=/dev/net/tun:/dev/net/tun"
      ];
      volumes = [ "gluetun:/config" ];
    };

    qbittorrent = {
      image = "lscr.io/linuxserver/qbittorrent:latest";
      environment = {
        PUID = "${toString config.users.users.qbit.uid}";
        PGID = "${toString config.users.groups.media.gid}";
        TZ = config.hostSpec.timezone;
        WEBUI_PORT = "8080";
      };
      volumes = [
        "/var/lib/qbittorrent/config:/config"
        "${mediaDir}/torrents:${mediaDir}/torrents"
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
    allowedTCPPorts = [ 6881 ];
    allowedUDPPorts = [ 6881 ];
  };

  # Create directories with correct permissions
  systemd.tmpfiles.rules = [
    "d /var/lib/qbittorrent/config 0775 qbit media -"

    # These are the actual directories on the host that qBittorrent will use via the mount
    "d ${mediaDir}/torrents 0775 qbit media -"
    "d ${mediaDir}/torrents/.incomplete 0775 qbit media -"
    "d ${mediaDir}/torrents/.watch 0775 qbit media -"
    "d ${mediaDir}/torrents/radarr 0775 qbit media -"
    "d ${mediaDir}/torrents/sonarr 0775 qbit media -"
    "d ${mediaDir}/torrents/bazarr 0775 qbit media -"

    "z ${mediaDir}/torrents 0775 qbit media -"
    "Z ${mediaDir}/torrents/.incomplete 0775 qbit media -"
    "Z ${mediaDir}/torrents/radarr 0775 qbit media -"
    "Z ${mediaDir}/torrents/sonarr 0775 qbit media -"
    "Z ${mediaDir}/torrents/bazarr 0775 qbit media -"
  ];

  users.users.qbit = {
    isSystemUser = true;
    uid = 985;
    group = "media";
  };
}
