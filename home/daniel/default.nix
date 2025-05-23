{ config, lib, pkgs, ... }:

{
  imports = [
    ../common/core
  ];

  home = {
    username = "daniel";
    homeDirectory = "/home/daniel";
  };
}