{
  description = "Your new nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    stylix.url = "github:danth/stylix";
  };

  outputs =
    { self
    , nixpkgs
    , stylix
    , home-manager
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
            #stylix.nixosModules.stylix
          ];
        };
        gusto = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
            ./hosts/gusto
          ];
        };
      };

      # Standalone home-manager configuration entrypoint
      # Available through 'home-manager --flake .#your-username@your-hostname'
      homeConfigurations = {
        "daniel@guppy" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
          extraSpecialArgs = { inherit inputs outputs; };
          # > Our main home-manager configuration file <
          modules = [
            ./home/common/core
            ./home/daniel
            ./home/daniel/guppy.nix
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
            ./home/common/core
            ./home/daniel
            ./home/daniel/gusto.nix
            # stylix.homeManagerModules.stylix # TODO: Do I need stylix on gusto? zsh? 
          ];
        };
      };
    };
}
