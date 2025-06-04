{ config, lib, pkgs, ... }:
{
  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_GB.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_IE.UTF-8";
      LC_IDENTIFICATION = "en_IE.UTF-8";
      LC_MEASUREMENT = "en_IE.UTF-8";
      LC_MONETARY = "en_IE.UTF-8";
      LC_NAME = "en_IE.UTF-8";
      LC_NUMERIC = "en_IE.UTF-8";
      LC_PAPER = "en_IE.UTF-8";
      LC_TELEPHONE = "en_IE.UTF-8";
      LC_TIME = "en_IE.UTF-8";
    };
  };

  # set timezone and clock settings
  time.timeZone = config.hostSpec.timezone;
  # if config.hostSpec.dualBoot is true, we want to use the hardware clock in local time
  # to avoid issues with dual booting with Windows
  # otherwise, default to false
  # this is useful for dual booting with Windows, which expects the hardware clock to be in local time
  # see https://nixos.wiki/wiki/Time#Hardware_clock_in_local_time
  time.hardwareClock = if config.hostSpec.dualBoot then true else false;
}