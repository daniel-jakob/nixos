{ self, deploy-rs }:

{
  guppy = {
    hostname = "192.168.0.70";
    sshUser = "daniel";
    profiles.system = {
      user = "root";
      path = deploy-rs.lib.x86_64-linux.activate.nixos
        self.nixosConfigurations.guppy;
      remoteBuild = true; # build on guppy itself
    };
    profiles.home = {
      user = "daniel";
      path = deploy-rs.lib.x86_64-linux.activate.home-manager
        self.homeConfigurations."daniel@guppy";
      remoteBuild = true;
    };
  };

  gusto = {
    hostname = "192.168.0.154";
    sshUser = "daniel";
    profiles.system = {
      user = "root";
      path = deploy-rs.lib.x86_64-linux.activate.nixos
        self.nixosConfigurations.gusto;
      remoteBuild = true;
    };
    profiles.home = {
      user = "daniel";
      path = deploy-rs.lib.x86_64-linux.activate.home-manager
        self.homeConfigurations."daniel@gusto";
      remoteBuild = true;
    };
  };
}
