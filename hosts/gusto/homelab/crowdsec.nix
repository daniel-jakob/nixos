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
  };
}
