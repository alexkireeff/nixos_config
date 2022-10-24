{
  pkgs,
  system,
}: {
  ${system} = {
    python = pkgs.mkShell {
      buildInputs = with pkgs; [
        mypy
        black
        python3
      ];

      shellHook = "${pkgs.zsh}/bin/zsh; exit";
    };

    # TODO I believe these shells will need to be put in their own directories for their relevant projects
    mlPython = pkgs.mkShell {
      buildInputs = with pkgs; [
        python3
        python3Packages.pytorch-bin # don't compile cuda from scratch
      ];

      shellHook = "${pkgs.zsh}/bin/zsh; exit";
    };

    bin = pkgs.mkShell {
      buildInputs = with pkgs; [
        # bin for patching
        patchelf
        # libraries for patching
        glibc
        openssl

        # view system calls
        strace

        # compiler
        gcc

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
      shellHook = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        export GLIBC=${pkgs.glibc}/lib
        export CRYPTO=${pkgs.openssl.out}/lib

        echo "Patching with patchelf";

        echo "get interpreter";
        echo "patchelf --print-interpreter BIN";
        echo "set interpreter";
        echo "patchelf --set-interpreter INTERPRETER BIN";

        echo "get rpath";
        echo "patchelf --print-rpath BIN";
        echo "set rpath";
        echo "patchelf --set-rpath RPATH BIN";

        echo "";

        echo "Compiling with gcc";

        echo "disable ASLR:";
        echo "sudo bash -c 'echo 0 > /proc/sys/kernel/randomize_va_space'";

        echo "disable buffer overflow protection";
        echo "-D_FORTIFY_SOURCE=0";

        echo "disable executable stack:";
        echo "-z execstack";

        echo "disable stack canaries:";
        echo "-fno-stack-protector";

        echo "disable Position Independent Executables:";
        echo "-no-pie";

        echo "compile 32 bit:";
        echo "-m32";
        ${pkgs.zsh}/bin/zsh
        exit'';
    };

    cuda = pkgs.mkShell {
      buildInputs = with pkgs; [
        cudatoolkit
        linuxPackages.nvidia_x11
      ];

      shellHook = "export CUDA_PATH=${pkgs.cudatoolkit}; ${pkgs.zsh}/bin/zsh; exit";
    };
  };
}
