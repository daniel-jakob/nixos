{ config, lib, pkgs, ... }:

{
  imports = [
    ../common/core
  ];

  home = {
    username = "daniel";
    homeDirectory = "/home/daniel";

    sessionVariables = {
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_CACHE_HOME = "$HOME/.cache";
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_STATE_HOME = "$HOME/.local/state"; # As per newer XDG specs
      XDG_BIN_HOME = "$HOME/.local/bin"; # Common practice, though not officially in the core spec for all vars
      # You might also want to add XDG_BIN_HOME to your PATH
      PATH = "$HOME/.local/bin:$PATH"; # Home Manager often handles PATH additions via programs.<name>.enable
    };
  };
}