#
{ config, pkgs, lib, ... }:

let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";

in {

  imports = [ "${home-manager}/nixos" ./hardware-configuration.nix ];

  # make swap device
  swapDevices =
    [{ device = "/swapfile";
      # RAM size + 1 GB
      size = (8 + 1) * 1024;
    }];

  # TODO FUTURE use btrfs if stable (or zfs if it gets a more permissive license)

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_hardened;

  boot.kernelModules = [ "tcp_bbr" ];

  # TODO put more security stuff in here
  boot.kernel.sysctl = {
    # Disable SysRq key
    "kernel.sysrq" = 0;
    # Ignore ICMP broadcasts
    "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
    # Ignore bad ICMP errors
    "net.ipv4.icmp_ignore_bogus_error_responses" =  1;
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
    ## Bufferfloat mitigations
    # Requires >= 4.9 & kernel module
    "net.ipv4.tcp_congestion_control" = "bbr";
    # Set network stack scheduler
    "net.core.default_qdisc" = "cake";
  };

  networking.hostName = "computer";
  networking.networkmanager.enable = true;

  time.timeZone = "America/New_York";

  nix.gc = {
    automatic = true;
    dates = "Monday 01:00 UTC";
    options = "--delete-older-than 7d";
  };

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.wlp0s20f3.useDHCP = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # TODO FUTURE make this services.interception-tools.enable = true;
  # when the error gets fixed
  services.interception-tools = {
    enable = true;
    plugins = [ pkgs.interception-tools-plugins.caps2esc ];
    udevmonConfig = ''- JOB: "${pkgs.interception-tools}/bin/intercept -g $DEVNODE | ${pkgs.interception-tools-plugins.caps2esc}/bin/caps2esc | ${pkgs.interception-tools}/bin/uinput -d $DEVNODE"
  DEVICE:
    EVENTS:
      EV_KEY: [KEY_CAPSLOCK, KEY_ESC]
    '';
  };
  console.keyMap = "us";

  # TODO user is here because if not then I can't load home-manager-user.service
  # but is there a way to load that without user being there?
  nix.allowedUsers = [ "root" "user" ];

  users = {
    mutableUsers = false;

    # password is disabled
    users.root.hashedPassword = ".";

    users.user = {
      shell = pkgs.zsh;
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      # permissions on below file should be 600
      # TODO FUTURE change password file to be secret when if that becomes a thing
      passwordFile = "/etc/nixos/user_pass_hash";

    };
  };

  environment.defaultPackages = lib.mkForce [];
  environment.systemPackages = with pkgs; [
    home-manager
    neovim
    # sway
    grim # screenshot
    swaylock # TODO set up idle screen locker
    swayidle # TODO set up idle timer
    wl-clipboard # clipboard
    mako # notifications daemon
    alacritty # terminal
    wofi
    
  ];

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;

  };

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;

  home-manager.users.user = {pkgs, ... }: {
    
    programs.home-manager.enable = true;


    services.gammastep = {
      enable = true;

      # I live here
      latitude = 38.897957;
      longitude = -77.0365560;

      temperature = {
        day = 6500;
        night = 2000;
      };
    };

    home.packages = with pkgs; [
      firefox
      # TODO configure firefox
      # Terminal font
      (nerdfonts.override {fonts = [ "Meslo" ]; })

    ];

    programs.zsh = {
      enable =true;
      initExtra = ''
      POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
      '';
      # TODO put zsh config in here, BUT make it automatically always start tmux

    };

    programs.neovim = {
      enable = true;
      plugins = with pkgs.vimPlugins; [
        airline # make bottom bar pretty
	dracula-vim # make theme pretty

      ];
      # TODO put dracula in here and then put vim config in here (change vim config a tad)

    };

    programs.git = {
      enable = true;
      userName = "user";
      userEmail = "user@user";
      # TODO think about putting legit info here
    };

    programs.tmux.enable = true;
    # TODO put tmux settings in here
    programs.ssh.enable = true;
    # TODO put server in here?

    wayland.windowManager.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      config = {
        terminal = "alacritty";
	# TODO change the absolute path when making the git repo
	menu = "wofi --style=/etc/nixos/wofi.css --show run";
	# TODO put custom keys in here too
	# TODO put brightness and volume keys here
      };
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
  };
  

  hardware = {
    opengl = {
      enable = true;
      driSupport = true;

    };
  };

  # TODO how to do login manager
  environment.loginShellInit = ''[[ "$(tty)" == /dev/tty1 ]] && sway'';
  security.pam.services.swaylock.text = "auth include login";

  # TODO might need this for ssh
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  networking.firewall.enable = true;

  security.sudo.execWheelOnly = true;

  # save all run programs to logs
  security.auditd.enable = true;
  security.audit.enable = true;
  security.audit.rules = [ "-a exit,always -F arch=b64 -S execve" ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}
