{
  pkgs,
  system,
}: {
  ${system} = {
    cudaPython = pkgs.mkShell {
      buildInputs = with pkgs; [
        black
        python3
        python3Packages.pytorch-bin # don't compile cuda from scratch
      ];

      shellHook = "${pkgs.zsh}/bin/zsh; exit";
    };

    testPython = pkgs.mkShell {
      buildInputs = with pkgs; [
        python3
      ];

      shellHook = "${pkgs.zsh}/bin/zsh; exit";
    };
  };
}
