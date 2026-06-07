{ config, pkgs, lib, ... }:
{
  # client ID and secret for Mealies's OpenID Connect integration with Pocket ID
  sops.secrets.mealie_oidc_client_id = {
    restartUnits = [ "mealie.service" ];
    # don't set owner here - let sops use root, template handles access
  };
  sops.secrets.mealie_oidc_client_secret = {
    restartUnits = [ "mealie.service" ];
  };

  sops.templates."mealie.env" = {
    owner = "root";
    group = "root";  
    mode = "0444";  # world-readable is fine since it's in /run/secrets which is 0751
    content = ''
      OIDC_CLIENT_ID=${config.sops.placeholder.mealie_oidc_client_id}
      OIDC_CLIENT_SECRET=${config.sops.placeholder.mealie_oidc_client_secret}
    '';
  };

  services.mealie = {
    enable = true;
    database.createLocally = true;
    port = 9000;
    settings = {
      FORWARDED_ALLOW_IPS = "*";
      LOG_LEVEL = "DEBUG";
      BASE_URL = "https://food.${config.hostSpec.domain}";
      ALLOW_SIGNUP = "true";
      OIDC_AUTH_ENABLED = "true";
      OIDC_SIGNUP_ENABLED = "true";
      OIDC_CONFIGURATION_URL = "https://id.${config.hostSpec.domain}/.well-known/openid-configuration";
      OIDC_PROVIDER_NAME = "Pocket ID";
    };
    credentialsFile = config.sops.templates."mealie.env".path;
  };
}
