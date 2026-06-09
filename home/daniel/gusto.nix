{ config, lib, pkgs, hostSpec, ... }:

{
  imports = [    
    ../common/core
    ../common/optional/starship.nix
    ../common/optional/eza.nix
  ];

  sops = {
    # Keep your age key config here
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt"; 
  };

  # FIX: Explicitly tie the secret to its yaml file using a relative path
  sops.secrets.hm_sample_secret = {
    sopsFile = ../../secrets/home/daniel/gusto.yaml; 
  };

  # Safely symlink the decrypted file output
  home.file.".config/sops-sample/secret.txt".source = 
    config.lib.file.mkOutOfStoreSymlink config.sops.secrets.hm_sample_secret.path;
}
