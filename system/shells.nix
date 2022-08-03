{
  pkgs,
  system,
}: {
  ${system} = {
    cudaPython = pkgs.mkShell {
      buildInputs = with pkgs; [
        mypy
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

    bin = pkgs.mkShell {
      buildInputs = with pkgs; [
        # debuggers
        rr
        gef
        ghidra # eventually only need ghidra

        # python exploit developement libraries
        python3
        python3Packages.pwntools
        python3Packages.angr
      ];

      # https://www.reddit.com/r/suckless/comments/m0hke6/ghidra_is_not_displayed_in_dwm/
      shellHook = "export _JAVA_AWT_WM_NONREPARENTING=1; ${pkgs.zsh}/bin/zsh; exit";
    };
  };
}
