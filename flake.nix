{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
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
      config = {
        allowUnfree = true;
        cudaSupport = true;
      };
    };
  in {
    nixosConfigurations = {
      laptop = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          home-manager = home-manager;
        };

        modules = [
          /etc/nixos/configuration.nix
          ./system/laptop.nix
          nur.nixosModules.nur
        ];
      };

      desktop = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          home-manager = home-manager;
        };

        modules = [
          /etc/nixos/configuration.nix
          ./system/desktop.nix
          nur.nixosModules.nur
        ];
      };
    };

    devShells = import ./system/shells.nix {
      pkgs = pkgs;
      system = system;
    };
  };
}
