{ config, lib, pkgs, ... }:
let
  domain = config.hostSpec.domain;
  baseDn = lib.concatMapStringsSep "," (part: "dc=${part}") (lib.splitString "." domain);
  authNetwork = "auth-stack";
  authNetworkSubnet = "10.90.0.0/24";
  authNetworkGateway = "10.90.0.1";
  lldapUid = 984;
  lldapGid = 984;
  lldapUrl = "ldap://lldap:3890";
  lldapBindDn = "uid=admin,ou=people,${baseDn}";
  smtp = config.homelab.smtp;
  smtpTls = {
    force_tls = "tls";
    starttls = "starttls";
    off = "none";
  }.${smtp.security};
in
{
  virtualisation = {
    podman.enable = true;
    oci-containers.backend = "podman";
    oci-containers.containers = {
      lldap = {
        image = "docker.io/lldap/lldap:stable";
        ports = [
          "127.0.0.1:17170:17170"
          "127.0.0.1:3890:3890"
        ];
        environmentFiles = [ config.sops.templates.lldap_env.path ];
        environment = {
          UID = toString lldapUid;
          GID = toString lldapGid;
          LLDAP_FORCE_LDAP_USER_PASS_RESET = "false";
        };
        volumes = [ "/var/lib/lldap:/data" ];
        extraOptions = [ "--network=${authNetwork}" ];
      };

      pocket-id = {
        image = "ghcr.io/pocket-id/pocket-id:v2";
        ports = [ "127.0.0.1:1411:1411" ];
        environmentFiles = [ config.sops.templates.pocket_id_env.path ];
        volumes = [ "/var/lib/pocket-id:/app/data" ];
        dependsOn = [ "lldap" ];
        extraOptions = [ "--network=${authNetwork}" ];
      };

      tinyauth = {
        image = "ghcr.io/steveiliop56/tinyauth:v5";
        ports = [ "127.0.0.1:3000:3000" ];
        environmentFiles = [ config.sops.templates.tinyauth_env.path ];
        volumes = [ "/var/lib/tinyauth:/data" ];
        dependsOn = [ "lldap" ];
        extraOptions = [ "--network=${authNetwork}" ];
      };

      auth-smoke-test = {
        image = "docker.io/traefik/whoami:latest";
        ports = [ "127.0.0.1:9080:80" ];
      };
    };
  };

  sops.secrets = {
    lldap_jwt_secret.restartUnits = [ "podman-lldap.service" ];
    lldap_key_seed.restartUnits = [ "podman-lldap.service" ];
    lldap_admin_password.restartUnits = [
      "podman-lldap.service"
      "podman-pocket-id.service"
      "podman-tinyauth.service"
    ];
    pocket_id_encryption_key.restartUnits = [ "podman-pocket-id.service" ];
  } // lib.optionalAttrs smtp.enable {
    ${smtp.passwordSopsKey}.restartUnits = [ "podman-pocket-id.service" ];
  };

  sops.templates = {
    lldap_env = {
      owner = "root";
      group = "root";
      mode = "0400";
      content = ''
        LLDAP_HTTP_URL=https://ldap.${domain}
        LLDAP_LDAP_BASE_DN=${baseDn}
        LLDAP_LDAP_USER_EMAIL=${config.hostSpec.email.personal}
        LLDAP_JWT_SECRET=${config.sops.placeholder.lldap_jwt_secret}
        LLDAP_KEY_SEED=${config.sops.placeholder.lldap_key_seed}
      '';
    };

    pocket_id_env = {
      owner = "root";
      group = "root";
      mode = "0400";
      content = ''
        APP_URL=https://id.${domain}
        TRUST_PROXY=true
        ENCRYPTION_KEY=${config.sops.placeholder.pocket_id_encryption_key}
        UI_CONFIG_DISABLED=true
        APP_NAME=Pocket ID
        EMAILS_VERIFIED=true
        ALLOW_USER_SIGNUPS=withToken
        VERSION_CHECK_DISABLED=true
        ANALYTICS_DISABLED=true
        LDAP_ENABLED=true
        LDAP_URL=${lldapUrl}
        LDAP_BIND_DN=${lldapBindDn}
        LDAP_BIND_PASSWORD=${config.sops.placeholder.lldap_admin_password}
        LDAP_BASE=${baseDn}
        LDAP_USER_SEARCH_FILTER=(objectClass=person)
        LDAP_USER_GROUP_SEARCH_FILTER=(objectClass=groupOfUniqueNames)
        LDAP_ATTRIBUTE_USER_UNIQUE_IDENTIFIER=entryUUID
        LDAP_ATTRIBUTE_USER_USERNAME=uid
        LDAP_ATTRIBUTE_USER_EMAIL=mail
        LDAP_ATTRIBUTE_USER_FIRST_NAME=givenName
        LDAP_ATTRIBUTE_USER_LAST_NAME=sn
        LDAP_ATTRIBUTE_GROUP_MEMBER=uniqueMember
        LDAP_ATTRIBUTE_GROUP_UNIQUE_IDENTIFIER=entryUUID
        LDAP_ATTRIBUTE_GROUP_NAME=cn
        LDAP_ADMIN_GROUP_NAME=lldap_admin
        LDAP_ATTRIBUTE_USER_PROFILE_PICTURE=avatar
      '' + lib.optionalString smtp.enable ''
        SMTP_HOST=${smtp.host}
        SMTP_PORT=${toString smtp.port}
        SMTP_FROM=${smtp.from}
        SMTP_USER=${smtp.username}
        SMTP_PASSWORD=${config.sops.placeholder.${smtp.passwordSopsKey}}
        SMTP_TLS=${smtpTls}
      '';
    };

    tinyauth_env = {
      owner = "root";
      group = "root";
      mode = "0400";
      content = ''
        TINYAUTH_APPURL=https://auth.${domain}
        TINYAUTH_DATABASE_PATH=/data/tinyauth.db
        TINYAUTH_AUTH_SECURECOOKIE=true
        TINYAUTH_AUTH_TRUSTEDPROXIES=127.0.0.1/32,10.0.0.0/8,192.168.0.0/16
        TINYAUTH_ANALYTICS_ENABLED=false
        TINYAUTH_LDAP_ADDRESS=${lldapUrl}
        TINYAUTH_LDAP_BINDDN=${lldapBindDn}
        TINYAUTH_LDAP_BINDPASSWORD=${config.sops.placeholder.lldap_admin_password}
        TINYAUTH_LDAP_BASEDN=${baseDn}
        TINYAUTH_LDAP_SEARCHFILTER=(uid=%s)
        TINYAUTH_APPS_AUTHTEST_CONFIG_DOMAIN=auth-test.${domain}
        TINYAUTH_APPS_AUTHTEST_LDAP_GROUPS=lldap_admin
      '';
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/lldap 0700 lldap lldap - -"
    "d /var/lib/pocket-id 0700 root root - -"
    "d /var/lib/tinyauth 0700 root root - -"
  ];

  users.users.lldap = {
    isSystemUser = true;
    uid = lldapUid;
    group = "lldap";
    home = "/var/lib/lldap";
  };

  users.groups.lldap = {
    gid = lldapGid;
  };

  systemd.services = {
    podman-auth-stack-network = {
      description = "Create Podman network for auth stack";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        ${pkgs.podman}/bin/podman network exists ${authNetwork} || \
          ${pkgs.podman}/bin/podman network create \
            --subnet ${authNetworkSubnet} \
            --gateway ${authNetworkGateway} \
            ${authNetwork}
      '';
    };

    podman-lldap = {
      after = [ "podman-auth-stack-network.service" ];
      requires = [ "podman-auth-stack-network.service" ];
      preStart = ''
        ${pkgs.coreutils}/bin/chown -R ${toString lldapUid}:${toString lldapGid} /var/lib/lldap
      '';
    };

    podman-pocket-id = {
      after = [ "podman-auth-stack-network.service" ];
      requires = [ "podman-auth-stack-network.service" ];
    };

    podman-tinyauth = {
      after = [ "podman-auth-stack-network.service" ];
      requires = [ "podman-auth-stack-network.service" ];
    };
  };
}
