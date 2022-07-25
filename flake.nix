{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          cudaSupport = true;
        };
      };
    in {
      devShell = pkgs.mkShell {
        buildInputs = with pkgs; [
          black
          python3
          python3Packages.pytorch
        ];

        shellHook = "{pkgs.zsh}/bin/zsh"; # TODO is there a way to only run the current shell?
      };
    });
}
