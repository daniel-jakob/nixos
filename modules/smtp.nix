{ config, lib, ... }:
let
  cfg = config.homelab.smtp;
in
{
  options.homelab.smtp = {
    enable = lib.mkEnableOption "shared SMTP configuration";

    host = lib.mkOption {
      type = lib.types.str;
      example = "mail.postale.io";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 465;
    };

    security = lib.mkOption {
      type = lib.types.enum [ "force_tls" "starttls" "off" ];
      default = "force_tls";
    };

    from = lib.mkOption {
      type = lib.types.str;
      example = "daniel@jakob.ie";
    };

    username = lib.mkOption {
      type = lib.types.str;
      example = "daniel@jakob.ie";
    };

    passwordSopsKey = lib.mkOption {
      type = lib.types.str;
      default = "smtp_password";
      description = "sops secret key name for the SMTP password.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Declare the secret once here, centrally
    sops.secrets.${cfg.passwordSopsKey} = {
      # no owner here — consuming services set their own templates
    };
  };
}
