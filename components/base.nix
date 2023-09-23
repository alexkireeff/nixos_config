{
  config,
  pkgs,
  lib,
  home-manager,
  ...
}: let
  CD = builtins.toString ./.;
in {
  imports = ["${home-manager}/nixos"];

  # TODO remove when fixed https://github.com/NixOS/nix/issues/8502
  services.logrotate.checkConfig = false;

  # TODO FUTURE use btrfs when stable (or zfs if it gets a more permissive license)

  boot = {
    # bootloader
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    loader.efi.efiSysMountPoint = "/boot";

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
    # TODO FUTURE ideally don't want this setting
    # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/config/shells-environment.nix#L176
    shellAliases = {
      ls = null;
      ll = null;
      l = null;
    };
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
        wl-clipboard

        # command line utilities
        rsync # remote sync
        dtach # for keeping ssh open
        tree # see whats in a dir
        unzip # open .zip files
        zip # make .zip files
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
          lean-nvim # lean syntax + infoview
        ];
      };

      programs.ssh = let
        ssh_key_file_path = "/etc/nixos/ssh_key";
        git_key_file_path = "/etc/nixos/git_key";
      in {
        enable = true;
        extraConfig =
          if (builtins.pathExists ssh_key_file_path)
          then
            if (builtins.pathExists git_key_file_path)
            then builtins.replaceStrings ["ssh_key" "git_key"] [ssh_key_file_path git_key_file_path] (builtins.readFile "${CD}/configs/ssh.config")
            else
              throw ''
                missing git key file
                Do:
                  sudo ssh-keygen -t ed25519 -N "" -C "git_key" -f ${git_key_file_path}
                  sudo chown user:users ${git_key_file_path} ${git_key_file_path}.pub
                  chmod 400 ${git_key_file_path}
                  chmod 444 ${git_key_file_path}.pub
              ''
          else
            throw ''
              missing ssh key file
              Do:
                sudo ssh-keygen -t ed25519 -N "" -C "ssh_key" -f ${ssh_key_file_path}
                sudo chown user:users ${ssh_key_file_path} ${ssh_key_file_path}.pub
                chmod 400 ${ssh_key_file_path}
                chmod 444 ${ssh_key_file_path}.pub
            '';
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
            else if builtins.elem config.networking.hostName ["desktop"]
            then builtins.readFile "${CD}/configs/zsh/remote-big.config"
            else if builtins.elem config.networking.hostName []
            then builtins.readFile "${CD}/configs/zsh/remote-small.config"
            else throw "unknown hostname"
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

    settings.allowed-users = ["root" "user"];
  };

  programs.zsh.enable = true;

  security = {
    # save all run programs to logs
    audit.enable = true;
    audit.rules = ["-a exit,always -F arch=b64 -S execve"];
    auditd.enable = true;

    sudo.execWheelOnly = true;
  };

  # TODO FUTURE remove udevmonConfig and plugins
  # https://github.com/NixOS/nixpkgs/issues/126681
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

    users.user = let
      password_file_path = builtins.toPath "/etc/nixos/user_pass_hash";
    in {
      extraGroups = ["wheel" "networkmanager" "video"];
      isNormalUser = true;
      # TODO FUTURE use secrets
      # https://nixos.wiki/wiki/Comparison_of_secret_managing_schemes
      hashedPassword =
        if (builtins.pathExists password_file_path)
        then (lib.removeSuffix "\n" (builtins.readFile password_file_path))
        else
          throw ''
            missing password file
            Do:
              mkpasswd --method=scrypt | sudo tee ${password_file_path}
              sudo chmod 400 ${password_file_path}
          '';
      shell = pkgs.zsh;
    };
  };
}
