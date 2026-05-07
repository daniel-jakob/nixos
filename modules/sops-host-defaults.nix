{ config, ... }:
{
  sops = {
    defaultSopsFile =
      builtins.toPath "${toString ../secrets/hosts}/${config.hostSpec.hostName}.yaml";
    age.keyFile = "/var/lib/sops-nix/key.txt";
    validateSopsFiles = false;
  };
}
