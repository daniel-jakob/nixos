{}:
{
  programs = {
    firefox = {
      enable = true;
      /* ---- EXTENSIONS ---- */
      # Check about:support for extension/add-on ID strings.
      # Valid strings for installation_mode are "allowed", "blocked",
      # "force_installed" and "normal_installed".
      package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
        extraPolicies = {
          DisableTelemetry = true;
          ExtensionSettings = {
            "*".installation_mode = "allowed"; # blocks all addons except the ones specified below
            # uBlock Origin
            "uBlock0@raymondhill.net" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
              installation_mode = "force_installed";
            };
            # Cattpuccin Mocha Mauve theme
            "{76aabc99-c1a8-4c1e-832b-d4f2941d5a7a}" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/catppuccin-mocha-mauve-git/latest.xpi";
              installation_mode = "force_installed";
            };
            # Return Youtube Dislike
            "{762f9885-5a13-4abd-9c77-433dcd38b8fd}" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/return-youtube-dislikes/latest.xpi";
              installation_mode = "force_installed";
            };
            # Improve Youtube!
            "{3c6bf0cc-3ae2-42fb-9993-0d33104fdcaf}" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/youtube-addon/latest.xpi";
              installation_mode = "force_installed";
            };
            # Old Reddit Redirect
            "{9063c2e9-e07c-4c2c-9646-cfe7ca8d0498}" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/old-reddit-redirect/latest.xpi";
              installation_mode = "force_installed";
            };
            # Reddit Enhancement Suite
            "jid1-xUfzOsOFlzSOXg@jetpack" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/reddit-enhancement-suite/latest.xpi";
              installation_mode = "force_installed";
            };
            # SponsorBlock for YouTube
            "sponsorBlocker@ajay.app" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
              installation_mode = "force_installed";
            };
          };
        };
      };
    };
  };
}