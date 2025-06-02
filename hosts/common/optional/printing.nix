{ pkgs, lib, config, ... }:
{
  services.printing = {
    enable = true; # Enable CUPS to print documents.
    # Other printing related options can be set here.
  };
}
