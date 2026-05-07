{ config, lib, ... }:
let
  domain = config.hostSpec.domain;
  smtp = config.homelab.smtp;
in
{
  sops.secrets.smtp_password = {
    restartUnits = [ "vaultwarden.service" ];
  };

  sops.secrets.vaultwarden_admin_token = {
    restartUnits = [ "vaultwarden.service" ];
  };

  sops.templates."vaultwarden.env" = lib.mkIf smtp.enable {
    owner = "vaultwarden";
    group = "vaultwarden";
    mode = "0400";
    content = ''
      SMTP_PASSWORD=${config.sops.placeholder.smtp_password}
      ADMIN_TOKEN=${config.sops.placeholder.vaultwarden_admin_token}
    '';
  };

  services.vaultwarden = {
    enable = true;
    environmentFile = config.sops.templates."vaultwarden.env".path;
    domain = "vault.${domain}";
      config = lib.mkMerge [
        {
        SIGNUPS_ALLOWED = true;
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 8222;

      }
      (lib.mkIf smtp.enable {
        SMTP_HOST = smtp.host;
        SMTP_PORT = smtp.port;
        SMTP_SECURITY = smtp.security;
        SMTP_FROM = smtp.from;
        SMTP_USERNAME = smtp.username;
      })
    ];
  };
}
