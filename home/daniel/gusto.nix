{ config, lib, pkgs, hostSpec, ... }:

{
  imports = [    
    ../common/core
    ../common/optional/starship.nix
    ../common/optional/eza.nix
    ];

  sops.secrets.hm_sample_secret = { };

  home.file.".config/sops-sample/secret.txt".source = config.sops.secrets.hm_sample_secret.path;
}
