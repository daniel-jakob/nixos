{
  hostName = "gusto";
  username = "daniel";
  userFullName = "Daniel Jakob";
  handle = "daniel-jakob";
  email = { personal = "daniel@jakob.ie"; };
  isServer = true;
  isHomelab = true;
  homelab = {
    mediaDir = "/media";
    network.devices = {
      gusto.ip = "192.168.1.222";
      modem.ip = "192.168.0.1";
      router.ip = "192.168.1.1";
      hassio.ip = "192.168.1.166";
      tp-link-switch.ip = "192.168.1.199";
    };
  };
  stateVersion = "23.11";
}
