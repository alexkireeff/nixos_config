{ config, pkgs, lib, ... }:

let
  home-manager = builtins.fetchTarball
    "https://github.com/nix-community/home-manager/archive/master.tar.gz";

  CD = builtins.toString ./.;

in {
  imports = [ "${home-manager}/nixos" ];

  environment.defaultPackages = lib.mkForce [ ];
  environment.systemPackages = with pkgs; [ home-manager ];

  environment.loginShellInit =
    ''[[ "$(tty)" == /dev/tty1 ]] && ${pkgs.sway}/bin/sway'';

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;

  home-manager.users.user = { pkgs, ... }: {

    programs.home-manager.enable = true;

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
      swaylock # lock screen
      swayidle # idle controller
      wl-clipboard # clipboard
      wofi # menu
      i3status # status for bar
    ];

    wayland.windowManager.sway = {
      enable = true;

      config = {
        terminal = "alacritty";
        menu = "wofi --style=${CD}/wofi.css --show run";
        focus.forceWrapping = false;
        focus.followMouse = true;

        bars = [{
          statusCommand = "%{pkgs.i3status}/bin/i3status";
          command = "${pkgs.sway}/bin/swaybar";
        }];
        # TODO put custom keys in here too
        # TODO put brightness and volume keys here
      };
    };

    services.swayidle = {
      # TODO on laptop close, hibernate computer
      enable = true;
      timeouts = [
        {
          timeout = 60 * 4;
          command = "${pkgs.swaylock}/bin/swaylock";
        }
        {
          timeout = 60 * 10;
          command = "systemctl suspend-then-hibernate";
        }
      ];
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

      ring-caps-lock-color = "ffffff";

      ring-ver-color = "0061ff";

      ring-wrong-color = "ff0000";

      indicator-radius = 10;
      indicator-idle-visible = true;
      indicator-caps-lock = false;

      inside-clear-color = "000000";

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

    programs.tmux = {
      enable = true;
      extraConfig = builtins.readFile "${CD}/tmux.config";
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
}
