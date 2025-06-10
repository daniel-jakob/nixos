{ config, lib, pkgs, ... }:

{
  options.hardware.intelAcceleration = {
    enable = lib.mkEnableOption "Intel hardware acceleration support";
    
    users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Users that need access to hardware acceleration";
    };
  };

  config = lib.mkIf config.hardware.intelAcceleration.enable {
    # Enable OpenGL and Intel drivers
    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver    # VAAPI driver for newer Intel GPUs
        intel-compute-runtime # OpenCL support
        intel-vaapi-driver   # VAAPI driver for older Intel GPUs
      ];
    };

    # Set Intel driver as default
    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = "iHD";
    };

    # Add users to necessary groups
    users.users = lib.mkMerge (map (username: {
      ${username}.extraGroups = [ "video" "render" ];
    }) config.hardware.intelAcceleration.users);
  };
}