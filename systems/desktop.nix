{
  config,
  pkgs,
  lib,
  home-manager,
  ...
}: let
  CD = builtins.toString ./.;
  pub_ssh_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGLXQbVQIF1/DuPfoA3+YpLpjH1geOTmEff71wDhNgGN user";
  pub_git_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOt307aOiM2fsBlTPIpfvTDZWjA7v+7nN60f7IuCWNm1 user";
in {
  imports = ["${CD}/../components/base.nix" "${CD}/hardware/desktop-hardware.nix" "${CD}/../components/remote-boot.nix"];

  # enable network card for remote-boot.nix
  boot.initrd.availableKernelModules = ["r8169"];

  # TODO SHOULD BE ABLE TO REMOVE NOW
  # remove this it sets up the ethernet interface
  # https://github.com/NixOS/nixpkgs/issues/157034
  networking.interfaces.enp34s0.useDHCP = lib.mkDefault true;

  environment.systemPackages = with pkgs; [];

  # nvidia driver
  hardware.opengl.enable = true;
  services.xserver.videoDrivers = ["nvidia"];

  networking.hostName = "desktop";

  services = {
    fail2ban.enable = true;
    logind.extraConfig = ''
      HandlePowerKey=suspend-then-hibernate
      HandleSuspendKey=ignore
      HandleHibernateKey=ignore
    '';
    openssh = {
      enable = true;
      allowSFTP = true; # sshfs

      settings = {
        X11Forwarding = true; # gui applications
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };
  };

  swapDevices = [
    {
      device = "/swapfile";
      # NOTE RAM size + 1 GB
      size = (32 + 1) * 1024;
    }
  ];

  users = {
    groups.git = {};

    users = {
      user.extraGroups = ["git"];
      git = {
        createHome = true;
        group = "git";
        hashedPassword = ".";
        home = "/var/git";
        homeMode = "770";
        isSystemUser = true;
        openssh.authorizedKeys.keys = [pub_git_key];
        shell = "${pkgs.git}/bin/git-shell";
      };
      user.openssh.authorizedKeys.keys = [pub_ssh_key];
    };
  };
}
