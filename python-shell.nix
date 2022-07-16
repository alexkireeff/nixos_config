{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  # TODO FUTURE use nix flake and then use nix run
  nativeBuildInputs = with pkgs; [
    black
    python3
    python3Packages.pandas
    python3Packages.pytorch
  ];

  shellHook = "exec zsh";
}
