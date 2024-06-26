{
  config,
  pkgs,
  lib,
  home-manager,
  impure-info,
  ...
}: let
  CD = builtins.toString ./.;
in {
  imports = ["${home-manager}/nixos"];

  # TODO FUTURE use next gen filesystem

  boot = {
    # bootloader
    loader.efi.canTouchEfiVariables = true; # for fde
    loader.efi.efiSysMountPoint = "/boot";
    loader.systemd-boot.editor = false;
    loader.systemd-boot.enable = true;

    # boot setup keyfile
    initrd.secrets = {
      "/crypto_keyfile.bin" = null;
    };

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
      # Do not send ICMP redirects
      "net.ipv4.conf.all.send_redirects" = 0;
      # Do not accept IP source route packets
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
    shellAliases = lib.mkForce {};
    defaultPackages = lib.mkForce [];
    systemPackages = [
      pkgs.home-manager
    ];
  };

  home-manager = {
    users.user = {pkgs, ...}: {
      home.packages = [
        pkgs.alejandra # nix formatter
        pkgs.sshfs # connect to ssh filesystem

        # command line utilities
        pkgs.dtach # for keeping ssh open
        pkgs.tree # see whats in a dir
        pkgs.unzip # open .zip files
        pkgs.zip # make .zip files
      ];

      programs.home-manager.enable = true;

      home.stateVersion = "22.05";

      programs.git = {
        enable = true;
        userEmail = "alexkireeff@gmail.com";
        userName = "Alex Kireeff";
      };

      programs.helix = {
        enable = true;
        settings = {
          editor = {
            bufferline = "always";
            line-number = "relative";
            middle-click-paste = false;
            mouse = false;
          };

          theme = "base16_terminal";
        };
      };

      programs.ssh = {
        enable = true;

        matchBlocks = {
          "desktop" = {
            extraOptions = {hostKeyAlias = "desktop";};
            hostname = impure-info.desktop_dns;
            identityFile = impure-info.ssh_key_path_string;
            identitiesOnly = true;
            user = "user";
          };

          "fde-desktop" = {
            extraOptions = {hostKeyAlias = "fde-desktop";};
            hostname = impure-info.desktop_dns;
            identityFile = impure-info.ssh_key_path_string;
            identitiesOnly = true;
            user = "root";
          };

          "gitserver" = {
            extraOptions = {hostKeyAlias = "gitserver";};
            hostname = impure-info.desktop_dns;
            identityFile = impure-info.git_key_path_string;
            identitiesOnly = true;
            user = "git";
          };

          "github.com" = {
            hostname = "github.com";
            identitiesOnly = true;
            identityFile = impure-info.git_key_path_string;
            user = "git";
          };
        };
      };

      programs.zsh = let
        dotDirectory = ".config/zsh";
      in {
        enable = true;
        dotDir = dotDirectory;
        # common configuration + device specific overrides
        initExtra =
          (builtins.readFile "${CD}/configs/zsh/common.config")
          + (
            if builtins.elem config.networking.hostName ["laptop"]
            then builtins.readFile "${CD}/configs/zsh/laptop.config"
            else ""
          );
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

    # TODO FUTURE remove experimental-features when they are no longer experimental
    extraOptions = ''
      experimental-features = nix-command flakes ca-derivations
    '';

    settings = {
      allowed-users = ["root" "user"];
      sandbox = true;
    };
  };

  programs.zsh.enable = true;

  security = {
    # save all run programs to logs
    audit.enable = true;
    audit.rules = ["-a exit,always -F arch=b64 -S execve"];
    auditd.enable = true;

    sudo.execWheelOnly = true;

    unprivilegedUsernsClone = true;
  };

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
  system.stateVersion = "22.05";

  time.timeZone = "America/New_York";

  users = {
    mutableUsers = false;

    # password is disabled
    users.root.hashedPassword = ".";

    users.user = {
      extraGroups = ["dialout" "networkmanager" "video" "wheel"];
      isNormalUser = true;
      # TODO FUTURE use secrets
      # https://nixos.wiki/wiki/Comparison_of_secret_managing_schemes
      hashedPassword = lib.removeSuffix "\n" (builtins.readFile impure-info.user_pass_hash_path_string);
      shell = pkgs.zsh;
    };
  };
}
