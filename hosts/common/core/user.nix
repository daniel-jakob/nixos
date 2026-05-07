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
      extraGroups = [ "networkmanager" "wheel" "video" "input" "render" ];
      packages = with pkgs; [
        rsync
        git
      ];
    };
  };
  programs.zsh.enable = true;
}
