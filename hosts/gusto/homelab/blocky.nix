{ config, pkgs, ... }:
{
  services.blocky = {
    enable = true;
    settings = {
      # Listening addresses for DNS.
      # 0.0.0.0:53 for all interfaces.
      # 192.168.1.10:53 for specific IP if you bind it to your server's static IP.
      blocking.listening = [ "0.0.0.0:53" ]; # Blocky will listen on standard DNS port

      # Upstream DNS servers for Blocky to forward requests to
      upstream.default = [
        "tls://1.1.1.1" # Cloudflare DNS over TLS
        "tls://1.0.0.1"
        # "https://dns.google/dns-query" # Google DNS over HTTPS
      ];

      # Ad-block lists (examples)
      blocking.blacklist = [
        "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
        "https://adaway.org/hosts.txt"
      ];

      # Local DNS records (This is what you want for 'myservername')
      # You can map hostnames to your local server's IP address.
      # This assumes your NixOS server's static local IP is 192.168.1.50
      blocking.local = {
        "*.jakob.ie" = "192.168.0.154";  # Wildcard for all subdomains
        "jakob.ie" = "192.168.0.154";    # Base domain
      };

      # Optional: Cache settings
      # cache.maxItems = 10000;
      # cache.maxNegativeItems = 1000;

      # Optional: Enable metrics (useful for Prometheus/Grafana)
      # metrics.enable = true;
      # httpPorts = [ ":4000" ]; # Port for Blocky's metrics/dashboard
    };
  };

  # Open firewall port for Blocky (UDP and TCP for DNS)
  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];
}