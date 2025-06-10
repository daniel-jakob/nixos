{ config, pkgs, ... }:
{

  # Enable Traefik service
  services.traefik = {
    enable = true;

    # Static configuration
    staticConfigOptions = {
      entryPoints = {
        web = {
          address = ":80";
        };
        websecure = {
          address = ":443";
        };
      };

      api = {
        dashboard = true;
        insecure = false;  # Only for testing!
      };
    };

    # Dynamic configuration
    dynamicConfigOptions = {
      http = {
        # Define services
        services = {
          jellyfin.loadBalancer.servers = [{ url = "http://127.0.0.1:8096"; }];
          immich.loadBalancer.servers = [{ url = "http://127.0.0.1:2283"; }];
          qbit.loadBalancer.servers = [{ url = "http://127.0.0.1:8080"; }];
        };

        # Define middlewares
        middlewares = {
          redirect-to-https = {
            redirectScheme = {
              scheme = "https";
              permanent = true;
            };
          };
        };

        # Define routers
        routers = {
          jellyfin = {
            rule = "Host(`jellyfin.jakob.ie`)";
            entryPoints = [ "web" ];
            service = "jellyfin";
          };
          immich = {
            rule = "Host(`photos.jakob.ie`)";
            entryPoints = [ "web" ];
            service = "immich";
          };
          qbit = {
            rule = "Host(`qbit.jakob.ie`)";
            entryPoints = [ "web" ];
            service = "qbit";
          };
        };
      };
    };
  };

  # Open firewall ports for Traefik
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  # Create directory for ACME storage
  systemd.tmpfiles.rules = [
    "d /var/lib/traefik 0755 traefik traefik - -"
    "f /var/lib/traefik/acme.json 0600 traefik traefik - -"
  ];
}