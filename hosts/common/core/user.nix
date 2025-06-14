{ config, lib, pkgs, ... }:
let
  hostSpec = config.hostSpec;
in
{
  users = {
    defaultUserShell = pkgs.zsh;
    users.${hostSpec.username} = {
      name = hostSpec.username;
      isNormalUser = true;
      description = hostSpec.userFullName;
      extraGroups = [ "networkmanager" "wheel" ];
      packages = with pkgs; [ # no matter the environment, these packages will be installed
        rsync
        git
      ];
    };
  };
  programs.zsh.enable = true;
}