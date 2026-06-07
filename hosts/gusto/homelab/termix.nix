{ ... }:
{
  virtualisation.oci-containers.containers = {
    termix = {
      image = "ghcr.io/lukegus/termix:latest";
      ports = [ "127.0.0.1:6300:8080" ];
      environment = {
        PORT = "8080";
      };
      volumes = [ "termix-data:/app/data" ];
    };
  };
}
