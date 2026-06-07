{ config, pkgs, ... }:
let
  cfg = config.services.couchdb;
  couchdbAdminUser = "admin";
  couchdbDatabase = "obsidian-vault";
in
{
  sops.secrets.couchdb_admin_password = {
    restartUnits = [ "couchdb.service" "couchdb-livesync-bootstrap.service" ];
  };

  sops.templates.couchdb_admin_ini = {
    owner = "couchdb";
    group = "couchdb";
    mode = "0400";
    content = ''
      [admins]
      ${couchdbAdminUser} = ${config.sops.placeholder.couchdb_admin_password}
    '';
  };

  sops.templates.couchdb_livesync_bootstrap_env = {
    owner = "root";
    group = "root";
    mode = "0400";
    content = ''
      COUCHDB_ADMIN_USER=${couchdbAdminUser}
      COUCHDB_ADMIN_PASSWORD=${config.sops.placeholder.couchdb_admin_password}
      COUCHDB_DATABASE=${couchdbDatabase}
    '';
  };

  services.couchdb = {
    enable = true;
    bindAddress = "127.0.0.1";
    port = 5984;

    # Keep admin credentials out of the Nix store.
    extraConfigFiles = [ config.sops.templates.couchdb_admin_ini.path ];

    # Mirrors the LiveSync init script settings declaratively.
    extraConfig = {
      couchdb = {
        single_node = true;
        max_document_size = 50000000;
      };

      chttpd = {
        enable_cors = true;
        require_valid_user = true;
        max_http_request_size = 4294967296;
      };

      chttpd_auth.require_valid_user = true;

      httpd = {
        enable_cors = true;
        "WWW-Authenticate" = "Basic realm=\"couchdb\"";
      };

      cors = {
        credentials = true;
        origins = "app://obsidian.md,capacitor://localhost,http://localhost";
        methods = "GET, PUT, POST, HEAD, DELETE, OPTIONS";
        headers = "accept, authorization, content-type, origin, referer";
      };
    };
  };

  # Idempotent bootstrap for the default LiveSync database.
  systemd.services.couchdb-livesync-bootstrap = {
    description = "Bootstrap CouchDB database for Obsidian LiveSync";
    wantedBy = [ "multi-user.target" ];
    after = [ "couchdb.service" ];
    requires = [ "couchdb.service" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Restart = "on-failure";
      RestartSec = "10s";
      EnvironmentFile = config.sops.templates.couchdb_livesync_bootstrap_env.path;
    };

    script = ''
      set -euo pipefail

      base_url="http://${cfg.bindAddress}:${toString cfg.port}"
      auth="''${COUCHDB_ADMIN_USER}:''${COUCHDB_ADMIN_PASSWORD}"

      for _ in $(seq 1 60); do
        if ${pkgs.curl}/bin/curl --silent --show-error --fail -u "$auth" "$base_url/_up" >/dev/null; then
          break
        fi
        sleep 2
      done

      response_file=$(mktemp)
      status=$(${pkgs.curl}/bin/curl --silent --show-error --output "$response_file" --write-out "%{http_code}" \
        -u "$auth" \
        -X PUT "$base_url/''${COUCHDB_DATABASE}")

      case "$status" in
        201|202|412)
          ;;
        *)
          cat "$response_file" >&2
          rm -f "$response_file"
          echo "Unexpected HTTP status while creating database: $status" >&2
          exit 1
          ;;
      esac

      rm -f "$response_file"
    '';
  };
}
