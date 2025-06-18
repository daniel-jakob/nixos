{ config, lib, pkgs, ... }:
{
  imports = [
    ../../../modules/host-spec.nix
    ./host-spec-setter.nix
    ./fastfetch
    ./tmux.nix
    ./zsh.nix
    ./git.nix
    ./direnv.nix
    ./ssh.nix
    ./zoxide.nix
    ./xdg.nix
  ];

  home = {
    username = config.hostSpec.username;
    homeDirectory = ${config.hostSpec.home};
  };

  programs = {
    home-manager.enable = true;
  };
}