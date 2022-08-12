{
  pkgs,
  system,
}: {
  ${system} = {
    testPython = pkgs.mkShell {
      buildInputs = with pkgs; [
        python3
      ];

      shellHook = "${pkgs.zsh}/bin/zsh; exit";
    };

    mlPython = pkgs.mkShell {
      buildInputs = with pkgs; [
        mypy
        black
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
    pkgs.stdenv.mkDerivation {
      name = "cuda-env-shell";
      buildInputs = with pkgs; [
        git gitRepo gnupg autoconf curl
        procps gnumake utillinux m4 gperf unzip
        cudatoolkit linuxPackages.nvidia_x11
        libGLU libGL
        xorg.libXi xorg.libXmu freeglut
        xorg.libXext xorg.libX11 xorg.libXv xorg.libXrandr zlib 
        ncurses5 stdenv.cc binutils
      ];
      shellHook = ''
         export CUDA_PATH=${pkgs.cudatoolkit}
         # export LD_LIBRARY_PATH=${pkgs.linuxPackages.nvidia_x11}/lib:${pkgs.ncurses5}/lib
         export EXTRA_LDFLAGS="-L/lib -L${pkgs.linuxPackages.nvidia_x11}/lib"
         export EXTRA_CCFLAGS="-I/usr/include"
      '';          
    };
  };


}
