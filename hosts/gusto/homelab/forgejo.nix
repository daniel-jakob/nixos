{ config, pkgs, lib, ... }:
let
  cfg = config.services.forgejo;
  srv = cfg.settings.server;
  domain = config.hostSpec.domain;
  smtp = config.homelab.smtp;
  smtpProtocol = {
    force_tls = "smtps";
    starttls = "smtp+starttls";
    off = "smtp";
  }.${smtp.security};
in
{
  sops.secrets.${smtp.passwordSopsKey} = lib.mkIf smtp.enable {
    restartUnits = [ "forgejo.service" ];
  };

  # sops.secrets.forgejo_runner_token = {
  #   restartUnits = [ "gitea-runner-default.service" ];
  # };

  # sops.templates.forgejo_env = {
  #   mode = "0400";
  #   restartUnits = [ "gitea-runner-default.service" ];
  #   owner = "root";
  #   group = "root";
  #   content = ''
  #     TOKEN=${config.sops.placeholder.forgejo_runner_token}
  #   '';
  # };

  services.forgejo = {
    enable = true;
    database.type = "postgres";
    # Enable support for Git Large File Storage
    lfs.enable = true;
    settings = lib.mkMerge [
      {
        server = {
          DOMAIN = "git.${domain}";
          # You need to specify this to remove the port from URLs in the web UI.
          ROOT_URL = "https://${srv.DOMAIN}/";
          HTTP_PORT = 3001;
          SSH_PORT = lib.head config.services.openssh.ports;
        };
        # You can temporarily allow registration to create an admin user.
        service.DISABLE_REGISTRATION = false;
        # Add support for actions, based on act: https://github.com/nektos/act
        actions = {
          ENABLED = true;
          DEFAULT_ACTIONS_URL = "github";
        };
      }
      (lib.mkIf smtp.enable {
        mailer = {
          ENABLED = true;
          PROTOCOL = smtpProtocol;
          SMTP_ADDR = smtp.host;
          SMTP_PORT = smtp.port;
          FROM = smtp.from;
          USER = smtp.username;
        };
      })
    ];
    secrets = lib.mkIf smtp.enable {
      mailer.PASSWD = config.sops.secrets.${smtp.passwordSopsKey}.path;
    };
  };

  # services.gitea-actions-runner = {
  #   package = pkgs.forgejo-runner;
  #   instances.monolith = {
  #     enable = true;
  #     name = "monolith";
  #     url = "${srv.ROOT_URL}";
  #     # Obtaining the path to the runner token file may differ
  #     # tokenFile should be in format TOKEN=<secret>, since it's EnvironmentFile for systemd
  #     tokenFile = config.sops.templates.forgejo_env.path;
  #     labels = [
  #       "ubuntu-latest:docker://node:16-bullseye"
  #       "ubuntu-22.04:docker://node:16-bullseye"
  #       "ubuntu-20.04:docker://node:16-bullseye"
  #       "ubuntu-18.04:docker://node:16-buster"     
  #       ## optionally provide native execution on the host:
  #       # "native:host"
  #     ];
  #   };
  # };
}
