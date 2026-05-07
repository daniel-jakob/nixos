{ config, pkgs, lib, ... }:
let
  domain = config.hostSpec.domain;
in
{
  # Dawarich is a self-hosted media request management tool that integrates with Radarr and Sonarr
  services.dawarich = {
    enable = true;
    webPort = 3002; # Reverse proxy port 3002
    localDomain = "timeline.${domain}";
  };
  # Dawarich's NixOS module enables nginx automatically and binds it to 0.0.0.0:80, conflicting with Traefik. Restrict nginx to localhost so Traefik owns the public port.
  services.nginx.virtualHosts."timeline.jakob.ie" = {
  listen = [
    { addr = "127.0.0.1"; port = 8081; }
  ];
};
}
