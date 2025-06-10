{ config, pkgs, ... }:

{
  services.authelia = {
    enable = true;
    # IMPORTANT: Generate a strong secret key for session encryption.
    # On your server, run: `openssl rand -base64 32` or similar.
    # KEEP THIS SECRET! If it changes, all sessions will be invalidated.
    session.secret = "YOUR_GENERATED_SESSION_SECRET_HERE"; # Replace with a strong, random 32-byte base64 string

    # IMPORTANT: Generate a strong HASHED password for initial admin user.
    # For a quick start (DO NOT USE IN PRODUCTION):
    # pkgs.authelia-password-hashing-utility/bin/authelia-gen-pwd --hash-algo argon2id "your_authelia_admin_password"
    # Example:
    # "argon2id:$argon2id$v=19$m=65536,t=3,p=4$ZmV5V2g1L2M1V281N2U3Zg$L1h5aDYvYjI2YjJjMjY3YjI2YjI2YjI2YjI="
    # Replace with the actual hash.
    users = [
      {
        username = "admin";
        # Hashed password for 'admin' user.
        # Use authelia-gen-pwd to generate: `pkgs.authelia-password-hashing-utility/bin/authelia-gen-pwd --hash-algo argon2id "your_authelia_admin_password"`
        password = "YOUR_HASHED_AUTHELIA_ADMIN_PASSWORD_HERE"; # Replace with the actual hash
        # email = "admin@jakob.ie"; # Optional: for password reset if you configure an SMTP server
        display_name = "Administrator";
        groups = [ "admins" ];
      }
      # Add more users as needed
      # {
      #   username = "jakob";
      #   password = "YOUR_HASHED_JAKOB_PASSWORD";
      #   email = "jakob@jakob.ie";
      #   groups = [ "users" ];
      # }
    ];

    # Authentication backend (file based is simplest for home use)
    authenticationBackend.file = {
      # Path to the users_database.yml (will be managed by NixOS)
      path = "/var/lib/authelia/users_database.yml";
      # disable_accept_all = false; # Set to true to disable accepting all credentials without 2FA
      # password_hashing = { algorithm = "argon2id"; }; # Default to argon2id
    };

    # Session storage. Redis is highly recommended for Docker setups and high availability.
    # If not using Redis, use 'file' or 'memory' (memory is not persistent).
    # You'll need to enable a Redis service in NixOS first if you want to use it.
    session.redis = {
      host = "localhost"; # Assuming Redis is on the same host, or specify Redis container name/IP
      port = 6379;
      database = 0;
      # password = "YOUR_REDIS_PASSWORD"; # If Redis is password protected
    };

    # SMTP server for password reset, notification, and 2FA (e.g., email-based 2FA)
    # This is essential for password resets and useful for some 2FA methods.
    # Replace with your SMTP server details.
    notifier.filesystem = {
      # This is for testing and logs to a file. For real emails, use the smtp notifier.
      filename = "/var/log/authelia/notification.log";
    };
    # notifier.smtp = {
    #   host = "smtp.yourprovider.com";
    #   port = 587; # Or 465 for SMTPS
    #   username = "your_email@yourprovider.com";
    #   password = "YOUR_EMAIL_APP_PASSWORD"; # Use an app-specific password if available
    #   sender = "Authelia <authelia@jakob.ie>"; # The email address emails will come from
    #   timeout = "5s";
    #   disable_html_emails = false;
    #   disable_tls_verification = false;
    # };

    # Access control rules (most important part for security)
    # This is a basic example; adjust to your needs.
    accessControl.defaultPolicy = "deny"; # Default to deny everything
    accessControl.rules = [
      {
        domain = [ "auth.jakob.ie" ]; # Authelia's own UI domain
        policy = "bypass"; # Allow direct access to Authelia's login page
      }
      {
        domain = [ "qbit.jakob.ie" ]; # Your qBittorrent domain
        policy = "two_factor"; # Require 2FA for qBittorrent
        # Optional: restrict to specific users/groups
        # subject = [ "group:users" "user:jakob" ];
      }
      # {
      #   domain = [ "jellyfin.jakob.ie" ];
      #   policy = "two_factor"; # Example for Jellyfin
      # }
      # {
      #   domain = [ "myserver.jakob.ie" ]; # If you have a dashboard or other services
      #   policy = "one_factor"; # Only require password
      # }
      # Add more rules for other services
    ];

    # 2FA configuration (highly recommended!)
    # To use TOTP (Google Authenticator, Authy):
    # This stores TOTP secrets in a SQLite database.
    duo_api = {}; # Even if not using Duo, this is needed for the db backend config
    webAuthn = {}; # For FIDO2 keys (YubiKey etc)

    storage.local = {
      path = "/var/lib/authelia/db.sqlite3"; # Path to Authelia's database (for TOTP secrets etc.)
    };

    # CORS settings (if you have applications on different subdomains that need to interact)
    # cors = {
    #   allowed_origins = [ "https://jakob.ie" "https://jellyfin.jakob.ie" ];
    #   allowed_methods = [ "OPTIONS" "GET" "POST" ];
    #   allowed_headers = [ "Content-Type" "Authorization" "X-Requested-With" ];
    #   exposed_headers = [ "Content-Disposition" ];<<
    #   allow_credentials = true;
    # };

    # Server address for Authelia itself
    server = {
      host = "0.0.0.0"; # Listen on all interfaces
      port = 9091; # Default Authelia port
    };

    # Logging
    logs = {
      level = "info"; # or "debug" for troubleshooting
      # file = "/var/log/authelia/authelia.log"; # Optional: log to a file
    };

    # Ensure Authelia can write to its data directories
    # The user/group is usually 'authelia'
    stateDir = "/var/lib/authelia";
    dataDir = "/var/lib/authelia"; # Explicitly define for consistency

  };

  # Create necessary directories and set permissions for Authelia
  systemd.tmpfiles.rules = [
    "d /var/lib/authelia 0750 authelia authelia -"
    "f /var/lib/authelia/users_database.yml 0640 authelia authelia -"
    "f /var/lib/authelia/db.sqlite3 0640 authelia authelia -"
    "d /var/log/authelia 0750 authelia authelia -"
    "f /var/log/authelia/notification.log 0640 authelia authelia -"
    # f /var/log/authelia/authelia.log 0640 authelia authelia - # If you enable file logging
  ];

  users.users.authelia = {
    isSystemUser = true;
    group = "authelia";
    home = "/var/lib/authelia";
    createHome = true;
  };
  users.groups.authelia = {};

  # Open the Authelia port in the firewall (only if you need direct access, otherwise Traefik handles it)
  # networking.firewall.allowedTCPPorts = [ 9091 ]; # Usually not needed if only Traefik accesses it.
}
