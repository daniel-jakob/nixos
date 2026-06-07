{ config, pkgs, ... }:
let
  domain = config.hostSpec.domain;
in
{
  sops.secrets = {
    paperless_oidc_client_id = { };
    paperless_oidc_client_secret = { };
  };

  sops.templates.paperless_env = {
    owner = "root";
    group = "root";
    mode = "0400";
    content = ''
      PAPERLESS_APPS=allauth.socialaccount.providers.openid_connect
      PAPERLESS_SOCIALACCOUNT_PROVIDERS={"openid_connect":{"SCOPE":["openid","profile","email"],"OAUTH_PKCE_ENABLED":true,"APPS":[{"provider_id":"pocket-id","name":"Pocket-ID","client_id":"${config.sops.placeholder.paperless_oidc_client_id}","secret":"${config.sops.placeholder.paperless_oidc_client_secret}","settings":{"server_url":"https://id.${domain}"}}]}}
    '';
  };

  services.paperless = {
    enable = true;
    consumptionDirIsPublic = true;
    environmentFile = config.sops.templates.paperless_env.path;
    settings = {
      PAPERLESS_CONSUMER_IGNORE_PATTERN = [
        ".DS_STORE/*"
        "desktop.ini"
      ];
      PAPERLESS_OCR_LANGUAGE = "deu+eng";
      PAPERLESS_OCR_USER_ARGS = {
        optimize = 1;
        pdfa_image_compression = "lossless";
      };
      # If behind a reverse proxy, set to the external URL. Port is 28981 by default.
      PAPERLESS_URL = "https://paperless.${domain}";
    };
  };
}
