{
  config,
  pkgs,
  lib,
  home-manager,
  ...
}: let
  CD = builtins.toString ./.;
  # TODO put this in a file outside the dir and then throw if it's not there?
  pub_ssh_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGLXQbVQIF1/DuPfoA3+YpLpjH1geOTmEff71wDhNgGN user";
  pub_git_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOt307aOiM2fsBlTPIpfvTDZWjA7v+7nN60f7IuCWNm1 user";
in {
  imports = ["${CD}/base.nix" "${CD}/remote-boot.nix"];

  # enable network card for remote-boot.nix
  boot.initrd.availableKernelModules = ["r8169"];

  environment.systemPackages = with pkgs; [qemu];

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
