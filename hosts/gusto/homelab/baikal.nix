{ config, ... }:
{
  services.baikal = {
    enable = true;
    group = "caldav";
    user = "caldav";
  };
}
