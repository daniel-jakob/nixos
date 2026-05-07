{pkgs, ...}: 
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
        forwardAgent = true;
        serverAliveCountMax = 3;
        serverAliveInterval = 5;
      };
    };
  };

  services.ssh-agent.enable = true;
}
