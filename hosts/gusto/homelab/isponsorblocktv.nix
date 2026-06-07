{ ... }:
{
  virtualisation.oci-containers.containers = {
    isponsorblocktv = {
      image = "ghcr.io/dmunozv04/isponsorblocktv:latest";
      volumes = [ "/var/lib/isponsorblocktv:/app/data" ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/isponsorblocktv 0700 root root - -"
  ];
}
