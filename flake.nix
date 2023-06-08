{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nur,
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      #config.contentAddressedByDefault = true; # TODO
    };
  in {
    nixosConfigurations = {
      laptop = nixpkgs.lib.nixosSystem {
        inherit pkgs;
        specialArgs = {
          home-manager = home-manager;
        };

        modules = [
          ./systems/laptop.nix
          nur.nixosModules.nur
        ];
      };

      desktop = nixpkgs.lib.nixosSystem {
        inherit pkgs;
        specialArgs = {
          home-manager = home-manager;
        };

        modules = [
          ./systems/desktop.nix
          nur.nixosModules.nur
        ];
      };
    };
  };
}
