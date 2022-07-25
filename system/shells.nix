{pkgs, system }: {
  ${system}.cudaPython = pkgs.mkShell {
    buildInputs = with pkgs; [
      black
      python3
      python3Packages.pytorch-bin # get the bin
    ];

    shellHook = "${pkgs.zsh}/bin/zsh; exit";
  };

}
