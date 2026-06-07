{ config, pkgs, lib, ... }:
{
  sops.secrets.ddnss_password = {
    owner = "root";
    mode = "0400";
    restartUnits = [ "ddclient.service" ];
  };

  services.ddclient = {
    enable = true;
    protocol = "dyndns2";
    server = "www.ddnss.de";
    ssl = true;
    use = "web, web=https://ip4.ddnss.de/meineip.php";
    username = "danieljakob";
    passwordFile = config.sops.secrets.ddnss_password.path;
    domains = [ "jakobpunktie.ddnss.de" ];
    extraConfig = ''
      script=/nic/update
    '';
  };
}
