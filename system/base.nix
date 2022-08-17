{
  config,
  pkgs,
  lib,
  home-manager,
  ...
}: let
  CD = builtins.toString ./.;
  password_file_path = /. + "/etc/nixos/user_pass_hash";
in {
  imports = ["${home-manager}/nixos"];

  # TODO FUTURE use btrfs when stable (or zfs if it gets a more permissive license)

  boot = {
    kernelPackages = pkgs.linuxPackages_hardened;

    kernelModules = ["tcp_bbr"];

    kernel.sysctl = {
      # Disable SysRq key
      "kernel.sysrq" = 0;
      # Ignore ICMP broadcasts
      "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
      # Ignore bad ICMP errors
      "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
      # Reverse path filter for spoof protection
      "net.ipv4.conf.default.rp_filter" = 1;
      "net.ipv4.conf.all.rp_filter" = 1;
      # SYN flood protection
      "net.ipv4.tcp_syncookies" = 1;
      # Don't accept ICMP redirects (MITM attacks)
      "net.ipv4.conf.all.accept_redirects" = 0;
      "net.ipv4.conf.default.accept_redirects" = 0;
      # Or secure redirects
      "net.ipv4.conf.all.secure_redirects" = 0;
      "net.ipv4.conf.default.secure_redirects" = 0;
      # Or on ipv6
      "net.ipv6.conf.all.accept_redirects" = 0;
      "net.ipv6.conf.default.accept_redirects" = 0;
      # Do not send ICMP redirects (we not hacker)
      "net.ipv4.conf.all.send_redirects" = 0;
      # Do not accept IP source route packets (we not router)
      "net.ipv4.conf.all.accept_source_route" = 0;
      "net.ipv6.conf.all.accept_source_route" = 0;
      # Protect against tcp time wait assasination hazards
      "net.ipv4.tcp_rfc1337" = 1;
      # Latency reduction
      "net.ipv4.tcp_fastopen" = 3;
      # Bufferfloat mitigations
      "net.ipv4.tcp_congestion_control" = "bbr";
      # Set network stack scheduler
      "net.core.default_qdisc" = "cake";
    };
  };

  console.keyMap = "us";

  environment = {
    defaultPackages = lib.mkForce [];
    systemPackages = with pkgs; [
      home-manager
    ];
  };

  home-manager = {
    users.user = {pkgs, ...}: {
      home.packages = with pkgs; [
        alejandra # nix formatter
        sshfs # connect to ssh filesystem

        # font
        (nerdfonts.override {fonts = ["RobotoMono"];})

        # nvim shared copy paste
        wl-copy
        wl-paste

        # command line utilities
        rsync # remote sync
        dtach # for keeping ssh open
        tree # see whats in a dir
        unzip # open .zip files
      ];

      programs.home-manager.enable = true;

      home.stateVersion = "22.05";

      programs.git = {
        enable = true;
        userEmail = "alexkireeff@gmail.com";
        userName = "Alex Kireeff";
      };

      programs.neovim = {
        enable = true;
        extraConfig = builtins.readFile "${CD}/configs/nvim.config";
        plugins = with pkgs.vimPlugins; [
          airline # make vim bottom bar pretty
          python-syntax # python syntax
          vim-nix # nix syntax
        ];
      };

      programs.ssh = {
        enable = true;
        extraConfig = builtins.readFile "${CD}/configs/ssh.config";
      };

      programs.zsh = let
        dotDirectory = ".config/zsh";
      in {
        enable = true;
        dotDir = dotDirectory;
        initExtra =
          if builtins.elem config.networking.hostName ["laptop"]
          then builtins.readFile "${CD}/configs/zsh/laptop.config"
          else if builtins.elem config.networking.hostName ["desktop"]
          then builtins.readFile "${CD}/configs/zsh/remote-big.config"
          else if builtins.elem config.networking.hostName []
          then builtins.readFile "${CD}/configs/zsh/remote-small.config"
          else throw "bad hostname";
        initExtraFirst = ''
          POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
        '';
        loginExtra = ''
          compinit -d "${dotDirectory}/zcompdump-$ZSH_VERSION"
        '';
        plugins = [
          {
            name = "powerlevel10k";
            src = pkgs.zsh-powerlevel10k;
            file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
          }
          {
            name = "powerlevel10k-config";
            src = lib.cleanSource (builtins.toPath "${CD}/configs/powerlevel10k-config");
            file = "p10k.config";
          }
          {
            name = "zsh-vi-mode";
            src = pkgs.zsh-vi-mode;
            file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
          }
        ];
      };

      xdg.userDirs = {
        enable = true;
        createDirectories = true;
        desktop = "$HOME/downloads";
        documents = "$HOME/downloads";
        download = "$HOME/downloads";
        music = "$HOME/downloads";
        pictures = "$HOME/downloads";
        publicShare = "$HOME/downloads";
        templates = "$HOME/downloads";
        videos = "$HOME/downloads";
      };
    };

    useGlobalPkgs = true;
    useUserPackages = true;
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  networking = {
    firewall.enable = true;
    networkmanager = {
      enable = true;
      insertNameservers = ["1.1.1.1" "1.0.0.1"];
    };
  };

  nix = {
    gc = {
      automatic = true;
      dates = "Monday 01:00 UTC";
      options = "--delete-older-than 7d";
    };

    # TODO FUTURE remove flake experimental when not experimental anymore
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    settings.allowed-users = ["root" "user"];
  };

  # Control brightness
  programs.light.enable = true;

  security = {
    # save all run programs to logs
    audit.enable = true;
    audit.rules = ["-a exit,always -F arch=b64 -S execve"];
    auditd.enable = true;

    sudo.execWheelOnly = true;
  };

  # TODO FUTURE remove udevmonConfig and plugins when error fixed
  services.interception-tools = {
    enable = true;
    plugins = [pkgs.interception-tools-plugins.caps2esc];
    udevmonConfig = ''
      - JOB: "${pkgs.interception-tools}/bin/intercept -g $DEVNODE | ${pkgs.interception-tools-plugins.caps2esc}/bin/caps2esc | ${pkgs.interception-tools}/bin/uinput -d $DEVNODE"
        DEVICE:
          EVENTS:
            EV_KEY: [KEY_CAPSLOCK, KEY_ESC]
    '';
  };

  # Don't change
  system.stateVersion = "21.11";

  time.timeZone = "America/New_York";

  users = {
    mutableUsers = false;

    # password is disabled
    users.root.hashedPassword = ".";

    users.user = {
      extraGroups = ["wheel" "networkmanager" "video"];
      isNormalUser = true;
      # TODO FUTURE when secrets become a thing, change this & add ssh keys
      # NOTE permissions on password_file_path file should be 600
      # NOTE linux uses sha-512: mkpasswd -m sha-512
      hashedPassword =
        if (builtins.pathExists password_file_path)
        then (lib.removeSuffix "\n" (builtins.readFile password_file_path))
        else throw "no user password file";
      shell = pkgs.zsh;
    };
  };
}
