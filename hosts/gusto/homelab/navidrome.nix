{ config, ... }:
let
  mediaDir = config.hostSpec.homelab.mediaDir;
  devices = config.hostSpec.homelab.network.devices;
in
{
  services.navidrome = {
    enable = true;
    group = "media";
    user = "navidrome";

    openFirewall = false;  # Reverse proxy port 4533
    settings = {
      Address = devices.gusto.ip;
      MusicFolder = "${mediaDir}/music";
    };
  };
}
