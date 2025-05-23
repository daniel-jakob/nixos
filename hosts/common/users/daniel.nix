{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:
{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.daniel = {
    name = "daniel";
    isNormalUser = true;
    description = "Daniel";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [ # no matter the environment, these packages will be installed
      rsync
      zsh
      git
    ];
    shell = pkgs.zsh;
  };
}