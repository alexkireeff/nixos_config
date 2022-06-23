{ config, pkgs, lib, ... }:

# TODO refactor everything so it doesn't make my eyes bleed

let
  home-manager = builtins.fetchTarball
    "https://github.com/nix-community/home-manager/archive/master.tar.gz";

  CD = builtins.toString ./.;

in {
  imports = [ "${home-manager}/nixos" ];


  # TODO FUTURE use btrfs if stable (or zfs if it gets a more permissive license)

  boot.kernelPackages = pkgs.linuxPackages_hardened;

  boot.kernelModules = [ "tcp_bbr" ];

  boot.kernel.sysctl = {
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

  environment.defaultPackages = lib.mkForce [ ];
  environment.systemPackages = with pkgs; [ home-manager pulseaudio ];

  environment.loginShellInit =
    ''[[ "$(tty)" == /dev/tty1 ]] && ${pkgs.sway}/bin/sway'';

  programs.light.enable = true;

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;

  home-manager.users.user = { pkgs, ... }: {

    programs.home-manager.enable = true;
    home.stateVersion = "22.05";

    # notifications daemon
    programs.mako = {
      enable = true;
      defaultTimeout = 10000;

    };

    home.packages = with pkgs; [
      nixfmt
      sshfs

      firefox
      # TODO FUTURE configure firefox
      # font
      (nerdfonts.override { fonts = [ "Meslo" ]; })

      # sway
      grim # screenshot
      swayidle # idle controller
      swaylock # lock screen
      wl-clipboard # clipboard
      wofi # menu
      i3status # status for bar

      # python
      python310
      python310Packages.pandas # TODO figure out how to allow access
      # python3Packages.bayesian-optimization # broken

      # command line utilities
      dtach
      tree
      unzip

      # other
      speedcrunch

    ];

    wayland.windowManager.sway = {
      enable = true;

      config = {
        menu = "wofi --style=${CD}/wofi.css --show run";
        modifier = "Mod1"; # TODO or maybe control
        terminal = "${pkgs.alacritty}/bin/alacritty";
        # https://github.com/nix-community/home-manager/blob/master/modules/services/window-managers/i3-sway/sway.nix

        focus.forceWrapping = false;
        focus.followMouse = true;

        bars = [{
          statusCommand = "i3status -c ${CD}/i3status.config";
          command = "${pkgs.sway}/bin/swaybar";
        }];

        keybindings = let
          cfg =
            config.home-manager.users.user.wayland.windowManager.sway.config;
        in lib.mkOptionDefault { "${cfg.modifier}+t" = "${cfg.terminal}"; };
      };
      extraConfig =
        "# Brightness\nbindsym XF86MonBrightnessDown exec light -U 1\nbindsym XF86MonBrightnessUp exec light -A 1\n\n# Volume\nbindsym XF86AudioRaiseVolume exec 'pactl set-sink-volume @DEFAULT_SINK@ +1%'\nbindsym XF86AudioLowerVolume exec 'pactl set-sink-volume @DEFAULT_SINK@ -1%'\nbindsym XF86AudioMute exec 'pactl set-sink-mute @DEFAULT_SINK@ toggle'\n      ";
    };

    services.swayidle = {
      enable = true;
      events = [{
        event = "before-sleep";
        command = "${pkgs.swaylock}/bin/swaylock";
      }];
      timeouts = [{
        timeout = 60 * 4;
        command =
          "[[ $(cat /sys/class/power_supply/ACAD/online) -eq 0 ]] && systemctl suspend-then-hibernate";
      }];
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

    programs.zsh = {
      enable = true;
      initExtraFirst = ''
        POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
        source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
      '';

      initExtra = builtins.readFile "${CD}/zsh.config";
    };

    programs.neovim = {
      enable = true;

      plugins = with pkgs.vimPlugins; [
        airline # make bottom bar pretty
        vim-nix # nix syntax
        python-syntax # python syntax
      ];

      extraConfig = builtins.readFile "${CD}/nvim.config";
    };

    programs.git = {
      enable = true;
      userName = "user";
      userEmail = "user@computer";
    };

    programs.ssh = {
      enable = true;
      extraConfig = builtins.readFile "${CD}/ssh.config";

    };

    programs.alacritty = {
      # make it not mess with the text when resizing window?
      enable = true;
      settings = {
        font = {
          normal = {
            family = "Meslo LGM Nerd Font";
            style = "Regular";

          };
          bold = {
            family = "Meslo LGM Nerd Font";
            style = "Bold";

          };
          italic = {
            family = "Meslo LGM Nerd Font";
            style = "Italic";

          };
          bold_italic = {
            family = "Meslo LGM Nerd Font";
            style = "Bold Italic";

          };
        };
      };
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
  };

  security.pam.services.swaylock.text = "auth include login";


  # TODO FUTURE remove udevmonConfig and plugins when error fixed
  # TODO FUTURE figure out how to make it transition to long press faster
  services.interception-tools = {
    enable = true;
    plugins = [ pkgs.interception-tools-plugins.caps2esc ];
    udevmonConfig = ''
      - JOB: "${pkgs.interception-tools}/bin/intercept -g $DEVNODE | ${pkgs.interception-tools-plugins.caps2esc}/bin/caps2esc | ${pkgs.interception-tools}/bin/uinput -d $DEVNODE"
        DEVICE:
          EVENTS:
            EV_KEY: [KEY_CAPSLOCK, KEY_ESC]
    '';
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true; # low level soundcard interface
    pulse.enable = true; # pulseaudio interface

  };

  services.logind = {
    extraConfig = ''
      HandlLidSwitch=suspend-then-hibernate
      HandlePowerKey=suspend-then-hibernate
      HandleSuspendKey=ignore
      HandleHibernateKey=ignore
    '';

  };

  # make swap device
  swapDevices = [{
    device = "/swapfile";
    # RAM size + 1 GB
    size = (8 + 1) * 1024;
  }];

  networking.hostName = "computer";
  networking.networkmanager = {
    enable = true;
    insertNameservers = [ "1.1.1.1" "1.0.0.1" ];

  };

  networking.firewall.enable = true;

  time.timeZone = "America/New_York";

  nix.gc = {
    automatic = true;
    dates = "Monday 01:00 UTC";
    options = "--delete-older-than 7d";
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  nix.allowedUsers = [ "root" "user" ];

  users = {
    mutableUsers = false;

    # password is disabled
    users.root.hashedPassword = ".";

    users.user = {
      shell = pkgs.zsh;
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "video" ];
      # permissions on below file should be 600
      # TODO FUTURE change password file to be secret when if that becomes a thing
      passwordFile = "/etc/nixos/user_pass_hash";

    };
  };

  hardware = {
    opengl = {
      enable = true;
      driSupport = true;

    };
  };

  security.sudo.execWheelOnly = true;

  # save all run programs to logs
  security.auditd.enable = true;
  security.audit.enable = true;
  security.audit.rules = [ "-a exit,always -F arch=b64 -S execve" ];

  # Don't change
  system.stateVersion = "21.11";

}
