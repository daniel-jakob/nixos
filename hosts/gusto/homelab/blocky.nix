{ config, ... }:
let
  domain = config.hostSpec.domain;
  devices = config.hostSpec.homelab.network.devices;
in
{
  services.blocky = {
    enable = true;
    settings = {
      # Listening port for DNS
      ports.dns = "127.0.0.1:53,${devices.gusto.ip}:53,10.100.0.1:53";

      # Upstream DNS servers
      upstreams.groups.default = [
        "tcp-tls:1.1.1.1:853"
        "tcp-tls:1.0.0.1:853"
      ];

      # Ad-block deny lists
      blocking.denylists = {
        ads = [
          "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
          "https://adaway.org/hosts.txt"
          "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/wildcard/multi.txt"
        ];
      };

      # Apply the deny list to all clients
      blocking.clientGroupsBlock.default = [ "ads" ];

      # Local DNS overrides
      customDNS.mapping = {
        "gusto.lan" = devices.gusto.ip;
        "modem.lan" = devices.modem.ip;
        "router.lan" = devices.router.ip;
        "hassio.lan" = devices.hassio.ip;
        "guppy.lan" = devices.guppy.ip;
        "tp-link-switch.lan" = devices."tp-link-switch".ip;
        "${domain}" = devices.gusto.ip;
        "*.${domain}" = devices.gusto.ip;
      };
    };
  };

  # Allow blocky to bind its listeners (LAN IP, wg0) before those addresses
  # are actually assigned; the sockets start receiving once the IPs appear.
  # This eliminates the boot-ordering race that crashed blocky at startup.
  boot.kernel.sysctl."net.ipv4.ip_nonlocal_bind" = 1;

  # Safety net: if blocky ever loses a startup race, keep retrying for longer
  # instead of hitting the restart limit and staying dead.
  systemd.services.blocky = {
    startLimitIntervalSec = 300;
    startLimitBurst = 20;
    serviceConfig.Restart = "on-failure";
    serviceConfig.RestartSec = "5s";
  };

  # Open firewall ports for DNS
  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];
}
