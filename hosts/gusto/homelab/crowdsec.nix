{ config, lib, ... }:
{ 
  services.crowdsec = {
    enable = true;
    
    # Declaratively grab the required detection scenarios
    hub.collections = [
      "crowdsecurity/linux"
      "crowdsecurity/traefik"
    ];

    # Tell CrowdSec exactly where the logs live and what type they are
    localConfig.acquisitions = [
      {
        source = "journalctl";
        journalctl_filter = [ "_SYSTEMD_UNIT=traefik.service" ];
        labels.type = "traefik";
      }
    ];

    settings = {
      # The API server enable flag lives under settings.general, not settings.lapi
      general.api.server = {
        enable = true;
        listen_uri = "127.0.0.1:8083";
      };

      # settings.lapi only holds credentialsFile — nothing else
      lapi = {
        credentialsFile = "/var/lib/crowdsec/local_api_credentials.yaml";
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/crowdsec 0755 crowdsec crowdsec - -"
  ];
}
