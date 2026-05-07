{ config, lib, pkgs, ... }:
{
  networking = {
    hostName = config.hostSpec.hostName; # Define your hostname.
    networkmanager.enable = true; # Enable networking
    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  };
}
