{}:
{
  programs = {
    kitty = {
      enable = true;
      themeFile = "Catppuccin-Mocha";
      shellIntegration.enableZshIntegration = true;
      font = {
        name = lib.mkForce "FiraCode Nerd Font";
        size = lib.mkForce 10;
      };
    };
  };
}