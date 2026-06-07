{ config, lib, ... }:
let
  baseDomain = config.hostSpec.domain;
  devices = config.hostSpec.homelab.network.devices;
  reverseProxyRouting = import ../../../modules/reverse-proxy-routing.nix { inherit lib; };

  standardServices = [
    { name = "jellyfin";  port = 8096; }
    { name = "immich";    port = 2283; subdomain = "photos"; priority = 1; }
    { name = "immich-public-proxy"; port = 2284; subdomain = "photos"; pathPrefix = "/share"; localOnly = false; priority = 2; }
    { name = "immich-public-proxy-short"; port = 2284; subdomain = "photos"; pathPrefix = "/s"; localOnly = false; priority = 3; }
    { name = "mealie";    port = 9000; subdomain = "food"; }
    { name = "forgejo";   port = 3001; subdomain = "git"; }
    { name = "paperless"; port = 28981; }
    { name = "music";     port = 4533; host = devices.gusto.ip; }
    { name = "radarr";    port = 7878; }
    { name = "sonarr";    port = 8989; }
    { name = "lidarr";    port = 8686; }
    { name = "readarr";   port = 8787; }
    { name = "prowlarr";  port = 9696; }
    { name = "bazarr";    port = 6767; }
    { name = "seerr";     port = 5055; }
    { name = "qbit";      port = 8080; middlewares = [ "qbit-security" ]; }
    { name = "vault";     port = 8222; }
    { name = "obsidian";  port = 5984; localOnly = false; }
    { name = "termix";    port = 6300; }
    { name = "hassio";    port = 8123; subdomain = "home"; host = devices.hassio.ip; }
    { name = "baikal";    port = 8008; subdomain = "calendar";}
    { name = "dawarich";  port = 3002; subdomain = "timeline"; }
    { name = "lldap";     port = 17170; subdomain = "ldap"; }
    { name = "pocket-id"; port = 1411; subdomain = "id"; }
    { name = "tinyauth";  port = 3000; subdomain = "auth"; }
    { name = "auth-smoke-test"; port = 9080; subdomain = "auth-test"; middlewares = [ "tinyauth" ]; }
    { name = "qbitrr";    port = 6969; subdomain = "qbitrr"; }
  ];

  traefikDefaults = {
    host = "127.0.0.1";
    entryPoints = [ "websecure" ];
    tls = true;
    certResolver = "letsencrypt";
    priority = null;
    middlewares = [ ];
    localOnly = true;
    pathPrefix = null;
    domain = null;
  };

  generated = reverseProxyRouting.generateTraefik {
    inherit baseDomain;
    services = standardServices;
    defaults = traefikDefaults;
  };
in
{
  sops.secrets.cloudflare_dns_api_token = {
    owner = "traefik";
    group = "traefik";
    mode = "0400";
    restartUnits = [ "traefik.service" ];
  };

  sops.templates.traefik_cloudflare_env = {
    owner = "traefik";
    group = "traefik";
    mode = "0400";
    content = ''
      CF_DNS_API_TOKEN=${config.sops.placeholder.cloudflare_dns_api_token}
    '';
  };

  # Enable Traefik service
  services.traefik = {
    enable = true;
    environmentFiles = [ config.sops.templates.traefik_cloudflare_env.path ];

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
        dashboard = false;
        insecure = false;  # Only for testing!
      };
      
      # Add Let's Encrypt ACME resolver
      certificatesResolvers.letsencrypt.acme = {
        email = config.hostSpec.email.personal;
        storage = "${config.services.traefik.dataDir}/acme.json";
        dnsChallenge.provider = "cloudflare";
      };
    };

    # Dynamic configuration
    dynamicConfigOptions = {
      http = {
        services = generated.generatedServices;

        # Define middlewares
        middlewares = {
          redirect-to-https = {
            redirectScheme = {
              scheme = "https";
              permanent = true;
            };
          };

          qbit-security = {
            headers = {
              browserXssFilter = true;
              contentTypeNosniff = true;
              forceSTSHeader = true;
              stsSeconds = 315360000;
              stsIncludeSubdomains = true;
              stsPreload = true;
              customFrameOptionsValue = "allow-from https://${baseDomain}";
            };
          };

          local-only = {
            ipWhiteList.sourceRange = [
              "127.0.0.1/32"      # the server itself
              "192.168.0.0/24"    # Everything from 192.168.0.0 to 192.168.0.255
              "192.168.1.0/24"    # Everything from 192.168.1.0 to 192.168.1.255
              "10.0.0.0/8"        # If you use VPNs like Tailscale
            ];
          };

          tinyauth = {
            forwardAuth = {
              address = "http://127.0.0.1:3000/api/auth/traefik";
              trustForwardHeader = true;
              authResponseHeaders = [
                "Authorization"
                "Remote-Email"
                "Remote-Name"
                "Remote-User"
              ];
            };
          };
        };

        routers = generated.generatedRouters // {
          redirect = {
            entryPoints = [ "web" ];
            rule = "HostRegexp(`.+`)";
            middlewares = [ "redirect-to-https" ];
            service = "jellyfin";
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
