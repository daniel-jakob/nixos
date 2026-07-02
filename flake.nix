{
  description = "Your new nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    stylix.url = "github:danth/stylix";

    # Deploy-rs
    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";

    # sops-nix
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    # Minecraft packaging/module overlay
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";

    # Comma (nix-index-database)
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self
    , nixpkgs
    , stylix
    , home-manager
    , deploy-rs
    , sops-nix
    , nix-minecraft
    , ...
    } @ inputs:
    let
      inherit (self) outputs;
    in
    {
      # NixOS configuration entrypoint
      # Available through 'nixos-rebuild --flake .#your-hostname'
      nixosConfigurations = {
        guppy = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          # > Our main nixos configuration file <
          modules = [
            ./hosts/guppy
            inputs.sops-nix.nixosModules.sops
            #stylix.nixosModules.stylix
          ];
        };
        gusto = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
            ./hosts/gusto
            inputs.sops-nix.nixosModules.sops#
            inputs.nix-index-database.nixosModules.nix-index
          ];
        };
      };

      # Standalone home-manager configuration entrypoint
      # Available through 'home-manager --flake .#your-username@your-hostname'
      homeConfigurations = {
        "daniel@guppy" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
          extraSpecialArgs = { 
	          inherit inputs outputs;
            hostSpec = import ./hosts/guppy/host-spec-attrs.nix;
          };
          # > Our main home-manager configuration file <
          modules = [
            ./home/daniel/guppy.nix
            inputs.sops-nix.homeManagerModules.sops
            stylix.homeManagerModules.stylix
          ];
        };
        "daniel@gusto" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
          extraSpecialArgs = { 
	          inherit inputs outputs;
            hostSpec = import ./hosts/gusto/host-spec-attrs.nix;
          };
          # > Our main home-manager configuration file <
          modules = [
            ./home/daniel/gusto.nix
            inputs.sops-nix.homeManagerModules.sops
            # stylix.homeManagerModules.stylix # TODO: Do I need stylix on gusto? zsh? 
          ];
        };
        "jakob@troll" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
          extraSpecialArgs = { 
            inherit inputs outputs;
            hostSpec = import ./home/troll/host-spec-attrs.nix;
          };
          # > Our main home-manager configuration file <
          modules = [
            ./home/jakob/troll.nix
            inputs.sops-nix.homeManagerModules.sops
            stylix.homeManagerModules.stylix
          ];
        };
      };

      deploy.nodes = import ./deploy.nix { inherit self deploy-rs; };
    };
}
