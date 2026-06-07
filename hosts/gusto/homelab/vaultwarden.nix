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

  # client ID and secret for Vaultwarden's OpenID Connect integration with Pocket ID
  sops.secrets.vaultwarden_oidc_client_id = {
    restartUnits = [ "vaultwarden.service" ];
  };
  sops.secrets.vaultwarden_oidc_client_secret = {
    restartUnits = [ "vaultwarden.service" ];
  };

  sops.templates."vaultwarden.env" = {
    owner = "root";
    group = "root";
    mode = "0400";
    content = ''
      ADMIN_TOKEN=${config.sops.placeholder.vaultwarden_admin_token}
      SSO_CLIENT_ID=${config.sops.placeholder.vaultwarden_oidc_client_id}
      SSO_CLIENT_SECRET=${config.sops.placeholder.vaultwarden_oidc_client_secret}
    '' + lib.optionalString smtp.enable ''
      SMTP_PASSWORD=${config.sops.placeholder.smtp_password}
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
        SSO_ENABLED = true;
        SSO_SIGNUPS_MATCH_EMAIL = true;
        SSO_ALLOW_UNKNOWN_EMAIL_VERIFICATION = false; # Only keep this on true if you are willing to accept the risks: https://github.com/dani-garcia/vaultwarden/wiki/Enabling-SSO-support-using-OpenId-Connect#on-sso_allow_unknown_email_verification
        SSO_PKCE = true; #Only set this to true if you enabled PKCE (recommended) in Pocket ID otherwise set it to false
        SSO_SCOPES = "openid email profile offline_access";
        SSO_AUTHORITY= "https://id.${domain}";
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
