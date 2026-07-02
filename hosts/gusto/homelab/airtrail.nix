{ config, lib, pkgs, ... }:
let
  domain = config.hostSpec.domain;
  network = "airtrail";
in
{
  sops.secrets = {
    airtrail_db_password.restartUnits = [
      "podman-airtrail-db.service"
      "podman-airtrail.service"
    ];
    airtrail_oidc_client_id.restartUnits = [ "podman-airtrail.service" ];
    airtrail_oidc_client_secret.restartUnits = [ "podman-airtrail.service" ];
  };

  sops.templates = {
    airtrail_db_env = {
      owner = "root";
      group = "root";
      mode = "0400";
      content = ''
        POSTGRES_DB=airtrail
        POSTGRES_USER=airtrail
        POSTGRES_PASSWORD=${config.sops.placeholder.airtrail_db_password}
      '';
    };

    airtrail_env = {
      owner = "root";
      group = "root";
      mode = "0400";
      content = ''
        ORIGIN=https://flights.${domain}
        DB_URL=postgres://airtrail:${config.sops.placeholder.airtrail_db_password}@airtrail-db:5432/airtrail
        OAUTH_ENABLED=true
        OAUTH_ISSUER_URL=https://id.${domain}/.well-known/openid-configuration
        OAUTH_CLIENT_ID=${config.sops.placeholder.airtrail_oidc_client_id}
        OAUTH_CLIENT_SECRET=${config.sops.placeholder.airtrail_oidc_client_secret}
        OAUTH_AUTO_REGISTER=true
        OAUTH_BUTTON_TEXT=Login with Pocket ID
        OAUTH_PROVIDER_NAME=Pocket ID
      '';
    };
  };

  virtualisation.oci-containers.containers = {
    airtrail-db = {
      image = "docker.io/postgres:16-alpine";
      environmentFiles = [ config.sops.templates.airtrail_db_env.path ];
      volumes = [ "/var/lib/airtrail/db:/var/lib/postgresql/data" ];
      extraOptions = [ "--network=${network}" ];
    };

    airtrail = {
      image = "docker.io/johly/airtrail:latest";
      ports = [ "127.0.0.1:6301:3000" ];
      environmentFiles = [ config.sops.templates.airtrail_env.path ];
      volumes = [ "/var/lib/airtrail/uploads:/app/uploads" ];
      dependsOn = [ "airtrail-db" ];
      extraOptions = [ "--network=${network}" ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/airtrail 0700 root root - -"
    "d /var/lib/airtrail/db 0700 root root - -"
    "d /var/lib/airtrail/uploads 0775 1000 1000 - -"
  ];

  systemd.services = {
    podman-airtrail-network = {
      description = "Create Podman network for AirTrail";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        ${pkgs.podman}/bin/podman network exists ${network} || \
          ${pkgs.podman}/bin/podman network create ${network}
      '';
    };

    podman-airtrail-db = {
      after = [ "podman-airtrail-network.service" ];
      requires = [ "podman-airtrail-network.service" ];
    };

    podman-airtrail = {
      after = [ "podman-airtrail-network.service" ];
      requires = [ "podman-airtrail-network.service" ];
    };
  };
}
