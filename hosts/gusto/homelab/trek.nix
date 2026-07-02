{ config, lib, ... }:
let
  domain = config.hostSpec.domain;
  dataDir = "/var/lib/trek";
  smtp = config.homelab.smtp;
  smtpTls = {
    force_tls = "tls";
    starttls = "starttls";
    off = "none";
  }.${smtp.security};
in
{
  sops.secrets = {
    trek_encryption_key.restartUnits = [ "podman-trek.service" ];
    trek_oidc_client_id.restartUnits = [ "podman-trek.service" ];
    trek_oidc_client_secret.restartUnits = [ "podman-trek.service" ];
  } // lib.optionalAttrs smtp.enable {
    ${smtp.passwordSopsKey}.restartUnits = [ "podman-trek.service" ];
  };

  sops.templates.trek_env = {
    owner = "root";
    group = "root";
    mode = "0400";
    content = ''
      NODE_ENV=production
      PORT=3000
      TZ=${config.hostSpec.timezone}
      LOG_LEVEL=info
      APP_URL=https://trek.${domain}
      TRUST_PROXY=1
      ENCRYPTION_KEY=${config.sops.placeholder.trek_encryption_key}
      OIDC_ISSUER=https://id.${domain}
      OIDC_CLIENT_ID=${config.sops.placeholder.trek_oidc_client_id}
      OIDC_CLIENT_SECRET=${config.sops.placeholder.trek_oidc_client_secret}
      OIDC_DISPLAY_NAME=Pocket ID
      ALLOW_INTERNAL_NETWORK=true
    '' + lib.optionalString smtp.enable ''
      SMTP_HOST=${smtp.host}
      SMTP_PORT=${toString smtp.port}
      SMTP_USER=${smtp.username}
      SMTP_PASS=${config.sops.placeholder.${smtp.passwordSopsKey}}
      SMTP_FROM=${smtp.from}
    '' + lib.optionalString (smtp.enable && smtpTls == "none") ''
      SMTP_SKIP_TLS_VERIFY=true
    '';
  };

  virtualisation.oci-containers.containers.trek = {
    image = "docker.io/mauriceboe/trek:latest";
    ports = [ "127.0.0.1:6302:3000" ];
    environmentFiles = [ config.sops.templates.trek_env.path ];
    volumes = [
      "${dataDir}/data:/app/data"
      "${dataDir}/uploads:/app/uploads"
    ];
    extraOptions = [
      "--read-only"
      "--security-opt=no-new-privileges:true"
      "--cap-drop=ALL"
      "--cap-add=CHOWN"
      "--cap-add=SETUID"
      "--cap-add=SETGID"
      "--tmpfs=/tmp:noexec,nosuid,size=64m"
    ];
  };

  systemd.tmpfiles.rules = [
    "d ${dataDir} 0755 root root - -"
    "d ${dataDir}/data 0755 root root - -"
    "d ${dataDir}/uploads 0755 root root - -"
    "d ${dataDir}/uploads/files 0755 root root - -"
    "d ${dataDir}/uploads/covers 0755 root root - -"
    "d ${dataDir}/uploads/avatars 0755 root root - -"
    "d ${dataDir}/uploads/photos 0755 root root - -"
  ];
}
