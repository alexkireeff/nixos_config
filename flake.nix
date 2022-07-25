{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
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
    nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        (import ../configuration.nix)
        (import ./system/laptop.nix)
      ];
    };
    devShells.${system}.cudaPython = pkgs.mkShell {
      buildInputs = with pkgs; [
        black
        python3
        python3Packages.pytorch-bin # get the bin
      ];

      shellHook = "${pkgs.zsh}/bin/zsh; exit";
    };
  };
}
