{ config, pkgs, ... }:
let
  domain = config.hostSpec.domain;
in
{
  services.paperless = {
    enable = true;
    consumptionDirIsPublic = true;
    settings = {
      PAPERLESS_CONSUMER_IGNORE_PATTERN = [
        ".DS_STORE/*"
        "desktop.ini"
      ];
      PAPERLESS_OCR_LANGUAGE = "deu+eng";
      PAPERLESS_OCR_USER_ARGS = {
        optimize = 1;
        pdfa_image_compression = "lossless";
      };
      PAPERLESS_URL = "https://paperless.${domain}"; # if behind a reverse proxy, set to the external URL. port = 28981 by default
    };
  };
}
