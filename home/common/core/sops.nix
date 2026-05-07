{ config, ... }:
{
  sops.defaultSopsFile =
    builtins.toPath "${toString ../../../secrets/home}/${config.hostSpec.username}/${config.hostSpec.hostName}.yaml";
}
