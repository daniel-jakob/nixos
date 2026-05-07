{ config, lib, pkgs, ... }:
{
  home.pointerCursor = {
    name = lib.mkForce "Bibata-Modern-Ice";
    package = lib.mkForce pkgs.bibata-cursors;
    size = lib.mkForce 20;
    gtk.enable = true;
  };
}
