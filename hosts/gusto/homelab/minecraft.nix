{ inputs, pkgs, ... }:
{
  imports = [
    inputs.nix-minecraft.nixosModules.minecraft-servers
  ];

  nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;

    servers."vanilla-survival" = {
      enable = true;
      package = pkgs.vanillaServers.vanilla-26_1;
      

      serverProperties = {
        gamemode = "survival";
        difficulty = "hard";
        # server-port = 25565; # Default Minecraft port
        simulation-distance = 10;
      };

      whitelist = { 
        Jakobs_Biscuit = "aeada51c-d436-4737-8304-39361a620336";
        hzboyo = "c80328cd-49ac-47ad-afd9-86f5ca32263b"; 
      };

      jvmOpts = "-Xmx4G -Xms2G";
    };
  };
}
