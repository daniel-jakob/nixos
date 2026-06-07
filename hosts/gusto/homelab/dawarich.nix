{ config, pkgs, lib, ... }:
let
  domain = config.hostSpec.domain;
in
{
  sops.secrets.dawarich_oidc_client_id = {
    restartUnits = [ "dawarich.service" ];
  };
  sops.secrets.dawarich_oidc_client_secret = {
    restartUnits = [ "dawarich.service" ];
  };

  sops.templates."dawarich.env" = {
    owner = "root";
    group = "root";
    mode = "0400";
    content = ''
      OIDC_CLIENT_ID=${config.sops.placeholder.dawarich_oidc_client_id}
      OIDC_CLIENT_SECRET=${config.sops.placeholder.dawarich_oidc_client_secret}
      OIDC_ISSUER=https://id.${domain}
      OIDC_REDIRECT_URI=https://timeline.${domain}/users/auth/openid_connect/callback
      OIDC_PKCE_ENABLED=true
      OIDC_PROVIDER_NAME=Pocket ID
    '';
  };

  services.dawarich = {
    enable = true;
    webPort = 3002; # Reverse proxy port 3002
    localDomain = "timeline.${domain}";
    extraEnvFiles = [ config.sops.templates."dawarich.env".path ];
  };

  # Dawarich's NixOS module enables nginx automatically and binds it to 0.0.0.0:80, conflicting with Traefik. Restrict nginx to localhost so Traefik owns the public port.
  services.nginx.virtualHosts."timeline.${domain}" = {
    listen = [ { addr = "127.0.0.1"; port = 8081; } ];
  };
}
