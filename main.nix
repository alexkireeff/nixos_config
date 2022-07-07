{
  config,
  pkgs,
  lib,
  ...
}: let
  computerName = "laptop";
  sshServer = false;

  CD = builtins.toString ./.;
  home-manager =
    builtins.fetchTarball
    "https://github.com/nix-community/home-manager/archive/master.tar.gz";
in {
  imports = ["${home-manager}/nixos"];

  # TODO FUTURE use btrfs if stable (or zfs if it gets a more permissive license)
  # TODO https://nixos.wiki/wiki/Remote_LUKS_Unlocking

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
    loginShellInit = ''[[ "$(tty)" == /dev/tty1 ]] && ${pkgs.sway}/bin/sway'';
    systemPackages = with pkgs; [
      home-manager
      pulseaudio
    ];
  };

  hardware.opengl = {
    enable = true;
    driSupport = true;
  };

  home-manager = {
    users.user = {pkgs, ...}: {
      home.packages = with pkgs; [
        alejandra # nix formatter
        sshfs # connect to ssh filesystem

        # font
        (nerdfonts.override {fonts = ["RobotoMono"]; })

        # sway
        grim # screenshot
        swayidle # idle controller
        swaylock # lock screen
        wl-clipboard # clipboard
        wofi # menu
        i3status # status for bar

        # command line utilities
        dtach # for keeping ssh open
        tree # see whats in a dir
        unzip # open .zip files

        # other
        speedcrunch # calculator
      ];

      programs.home-manager.enable = true;

      home.stateVersion = "22.05";

      wayland.windowManager.sway = {
        config = {
          bars = [
            {
              statusCommand = "i3status -c ${CD}/i3status.config";
              command = "${pkgs.sway}/bin/swaybar";
            }
          ];

          focus.forceWrapping = false;
          focus.followMouse = true;

          keybindings = let
            cfg = config.home-manager.users.user.wayland.windowManager.sway.config;
          in
            lib.mkOptionDefault {
              "${cfg.modifier}+t" = "${cfg.terminal}";
            };

          menu = "wofi --style=${CD}/wofi.css --show run";
          modifier = "Mod1";
          terminal = "${pkgs.alacritty}/bin/alacritty";
        };

        enable = true;

        extraConfig = "# Brightness\nbindsym XF86MonBrightnessDown exec light -U 1\nbindsym XF86MonBrightnessUp exec light -A 1\n\n# Volume\nbindsym XF86AudioRaiseVolume exec 'pactl set-sink-volume @DEFAULT_SINK@ +1%'\nbindsym XF86AudioLowerVolume exec 'pactl set-sink-volume @DEFAULT_SINK@ -1%'\nbindsym XF86AudioMute exec 'pactl set-sink-mute @DEFAULT_SINK@ toggle'\n      ";
      };

      # blue light filter
      services.gammastep = {
        enable = true;
        latitude = 38.897957;
        longitude = -77.036556;
        temperature = {
          day = 6500;
          night = 2000;
        };
      };

      services.swayidle = {
        enable = true;
        events = [
          {
            event = "before-sleep";
            command = "${pkgs.swaylock}/bin/swaylock";
          }
        ];
        timeouts = [
          {
            timeout = 60 * 4;
            command = "[[ $(cat /sys/class/power_supply/ACAD/online) -eq 0 ]] && systemctl suspend-then-hibernate";
          }
        ];
      };

      programs.alacritty = {
        # make it not mess with the text when resizing window?
        enable = true;
        settings = {
          key_bindings = [
            {
              key = "N";
              mods = "Control|Shift";
              action = "SpawnNewInstance";
            }
          ];
          font = {
            bold = {
              family = "Roboto Mono Nerd Font";
              style = "Bold";
            };
            bold_italic = {
              family = "Roboto Mono Nerd Font";
              style = "Bold Italic";
            };
            italic = {
              family = "Roboto Mono Nerd Font";
              style = "Italic";
            };
            normal = {
              family = "Roboto Mono Nerd Font";
              style = "Regular";
            };
          };
        };
      };

      programs.firefox = {
        enable = true;
        # TODO about:config: pdf size width
        # TODO settings: privacy ones
          # TODO search engines: !g google, !w wikipedia, !s scholar, !d ddg by default
        # TODO extensions: tridactyl, ublock, cookie manager, privacy badger, video speed controller, dark reader
      };

      programs.git = {
        enable = true;
        userEmail = "user@computer";
        userName = "user";
      };

      # notifications daemon
      programs.mako = {
        enable = true;
        defaultTimeout = 10000;
      };

      programs.swaylock.settings = {
        show-failed-attempts = false;

        font-size = 0;

        color = "000000";

        ring-color = "ffffff";
        inside-color = "000000";
        line-color = "000000";
        text-color = "000000";

        ring-clear-color = "ffffff";
        inside-clear-color = "000000";
        line-clear-color = "000000";
        text-clear-color = "000000";

        ring-caps-lock-color = "ffffff";
        inside-caps-lock-color = "000000";
        line-caps-lock-color = "000000";
        text-caps-lock-color = "000000";

        ring-ver-color = "0061ff";
        inside-ver-color = "000000";
        line-ver-color = "000000";
        text-ver-color = "000000";

        ring-wrong-color = "ff0000";
        inside-wrong-color = "000000";
        line-wrong-color = "000000";
        text-wrong-color = "000000";

        indicator-radius = 10;
        indicator-idle-visible = true;
        indicator-caps-lock = false;

        disable-caps-lock-text = true;
      };

      programs.neovim = {
        enable = true;
        extraConfig = builtins.readFile "${CD}/nvim.config";
        plugins = with pkgs.vimPlugins; [
          airline # make vim bottom bar pretty
          python-syntax # python syntax
          vim-nix # nix syntax
        ];
      };

      programs.ssh = {
        enable = true;
        extraConfig = builtins.readFile "${CD}/ssh.config";
      };

      programs.zsh = let
        dotDirectory = ".config/zsh";
      in {
        enable = true;
        dotDir = dotDirectory;
        initExtra = builtins.readFile "${CD}/zsh.config";
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
            src = lib.cleanSource (builtins.toPath "${CD}/powerlevel10k-config");
            file = "p10k.config";
          }
          {
            name = "zsh-vi-mode";
            src = pkgs.zsh-vi-mode;
            file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
          }
        ];
      };
    };

    useGlobalPkgs = true;
    useUserPackages = true;
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  networking = {
    firewall.enable = true;
    hostName = "computer";
    networkmanager = {
      enable = true;
      insertNameservers = ["1.1.1.1" "1.0.0.1"];
    };
  };

  nix.gc = {
    automatic = true;
    dates = "Monday 01:00 UTC";
    options = "--delete-older-than 7d";
  };

  nix.allowedUsers = ["root" "user"];

  # Control laptop screen brightness
  programs.light.enable = true;

  security = {
    # save all run programs to logs
    audit.enable = true;
    audit.rules = ["-a exit,always -F arch=b64 -S execve"];
    auditd.enable = true;

    sudo.execWheelOnly = true;

    # Let sway unlock laptop
    pam.services.swaylock.text = "auth include login";
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

  services.logind = {
    extraConfig = ''
      HandlLidSwitch=suspend-then-hibernate
      HandlePowerKey=suspend-then-hibernate
      HandleSuspendKey=ignore
      HandleHibernateKey=ignore
    '';
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true; # low level soundcard interface
    pulse.enable = true; # pulseaudio interface
  };

  # make swap device
  swapDevices = [
    {
      device = "/swapfile";
      # RAM size + 1 GB
      size = (8 + 1) * 1024;
    }
  ];

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
      # permissions on below file should be 600
      # TODO FUTURE change password file to be secret when if that becomes a thing
      passwordFile = "/etc/nixos/user_pass_hash";
      shell = pkgs.zsh;
    };
  };
}
