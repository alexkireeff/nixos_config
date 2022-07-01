{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  # TODO update shell prompt to include a string with the shell name
  nativeBuildInputs = with pkgs; [
    black
    python3
    python3Packages.pandas
    python3Packages.pytorch
  ];
}
