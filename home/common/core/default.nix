{ config, lib, pkgs, ... }:
let
  hostSpec = config.hostSpec;
in
{
  imports = [
    ../../../modules/host-spec.nix
    ./host-spec-setter.nix
    ./sops.nix
    ./fastfetch
    ./tmux.nix
    ./zsh.nix
    ./git.nix
    ./direnv.nix
    ./ssh.nix
    ./zoxide.nix
    ./xdg.nix
    ./nh.nix
  ];

  home = {
    username = hostSpec.username;
    homeDirectory = hostSpec.home;
    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = hostSpec.stateVersion;
  };

  programs = {
    home-manager.enable = true;
  };
}
