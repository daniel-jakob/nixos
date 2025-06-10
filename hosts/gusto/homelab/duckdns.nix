{ config, pkgs, ... }:
{
  services.duckdns = {
    enable = true;
    domain = "danieljakob";
    tokenFile = "/run/duckdns/token";
  };
}