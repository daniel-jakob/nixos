{ config, ... }:
{
  home.sessionVariables = {
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state"; # As per newer XDG specs
    XDG_BIN_HOME = "$HOME/.local/bin"; # Common practice, though not officially in the core spec for all vars
    PATH = "$HOME/.local/bin:$PATH"; # Home Manager often handles PATH additions via programs.<name>.enable
  };
  
  xdg = {
    mime.enable = true;

    userDirs = {
      enable = true;
      directories = {
        DOWNLOAD = "${config.hostSpec.home}/Downloads";
        DESKTOP = "${config.hostSpec.home}/Desktop";
        TEMPLATES = "${config.hostSpec.home}/Templates";
        PUBLICSHARE = "${config.hostSpec.home}/Public";
        DOCUMENTS = "${config.hostSpec.home}/Documents";
        MUSIC = "${config.hostSpec.home}/Music";
        PICTURES = "${config.hostSpec.home}/Pictures";
        VIDEOS = "${config.hostSpec.home}/Videos";
        DOWNLOAD = "${config.hostSpec.home}/Downloads";

      };
    };
    
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "firefox.desktop"; # Example for setting Firefox as the default web browser
    };
  };
}