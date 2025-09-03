{ config, lib, hostSpec, ... }:
{
  imports =
    lib.optional hostSpec.bluetooth ./bluetooth.nix
    ++ lib.optional hostSpec.wifi ./wifi.nix
    ++ lib.optional hostSpec.nvidhoia ./nvidia.nix
    ++ lib.optional hostSpec.printer ./printer.nix
    ++ lib.optional hostSpec.audio ./audio.nix
    ++ lib.optional hostSpec.virtualisation ./virtualisation.nix
    ++ lib.optional (hostSpec.windowManager != null) ./${hostSpec.windowManager}
    ;
}