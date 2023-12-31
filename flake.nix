{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

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
    pkgs = import nixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true;
      # TODO CA derivations currently broken
      # https://github.com/NixOS/nixpkgs/pull/214044
      # config.contentAddressedByDefault = true;
    };
    impure-info = {
      ssh_key_path_string = "/etc/nixos/ssh_key";
      git_key_path_string = "/etc/nixos/git_key";
      user_pass_hash_path_string = "/etc/nixos/user_pass_hash";
    };
  in {
    nixosConfigurations = {
      laptop = nixpkgs.lib.nixosSystem {
        inherit pkgs;
        specialArgs = {
          inherit home-manager impure-info;
        };

        modules = [
          ./systems/laptop.nix
          nur.nixosModules.nur
        ];
      };

      desktop = nixpkgs.lib.nixosSystem {
        inherit pkgs;
        specialArgs = {
          inherit home-manager impure-info;
        };

        modules = [
          ./systems/desktop.nix
          nur.nixosModules.nur
        ];
      };
    };
  };
}
