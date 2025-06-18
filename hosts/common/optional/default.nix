{ config, lib, ... }:
{
  imports =
    lib.optional config.hostSpec.bluetooth ./bluetooth.nix
    ++ lib.optional config.hostSpec.wifi ./wifi.nix
    ++ lib.optional config.hostSpec.nvidia ./nvidia.nix
    ++ lib.optional config.hostSpec.printer ./printer.nix
    ++ lib.optional config.hostSpec.audio ./audio.nix
    ++ lib.optional config.hostSpec.virtualisation ./virtualisation.nix
    +++ lib.optional (config.hostSpec.windowManager != null ./${config.hostSpec.windowManager}
    ;
}