{
  config,
  pkgs,
  lib,
  home-manager,
  ...
}: let
  CD = builtins.toString ./.;
  pub_ssh_key = "AAAAC3NzaC1lZDI1NTE5AAAAIGLXQbVQIF1/DuPfoA3+YpLpjH1geOTmEff71wDhNgGN";
  pub_git_key = "AAAAC3NzaC1lZDI1NTE5AAAAIOt307aOiM2fsBlTPIpfvTDZWjA7v+7nN60f7IuCWNm1";
in {
  imports = ["${CD}/base.nix" "${CD}/remote-boot.nix"];
  # TODO want to be able to recover from bad config, do that by making a service run during initrd that pulls from git repo and runs update

  # enable network card for remote-boot.nix
  boot.initrd.availableKernelModules = ["r8169"];

  environment.systemPackages = [];

  # nvidia driver
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
      forwardX11 = true;
      passwordAuthentication = false;
      permitRootLogin = "no";
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
      git = {
        createHome = true;
        group = "git";
        hashedPassword = ".";
        home = "/var/git";
        isSystemUser = true;
        openssh.authorizedKeys.keys = [pub_git_key];
        shell = "${pkgs.git}/bin/git-shell";
      };
      user.openssh.authorizedKeys.keys = [pub_ssh_key];
    };
  };
}
