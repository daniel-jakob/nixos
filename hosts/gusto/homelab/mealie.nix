{ config, pkgs, ... }:

{
  services.mealie = {
    enable = true;
    database.createLocally = true;
    port = 9000;
  };
}
