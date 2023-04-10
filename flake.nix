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

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        utils.follows = "flake-utils";
      };
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nur,
    deploy-rs,
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
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

    deploy.nodes.laptop.profiles.system = {
        user = "root";
        path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.laptop;
    };

    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
  };
}
