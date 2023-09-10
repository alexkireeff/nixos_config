{
  config,
  pkgs,
  lib,
  home-manager,
  ...
}: let
  CD = builtins.toString ./.;
  # TODO define ssh key locations in 1 place rather than 2 and define this in just one place (flake?)
  ssh_key_file_path = "/etc/nixos/ssh_key";
  git_key_file_path = "/etc/nixos/git_key";
in {
  imports = ["${CD}/../components/base.nix" "${CD}/hardware/desktop-hardware.nix" "${CD}/../components/remote-boot.nix"];

  # enable network card for remote-boot.nix
  config.boot.initrd.availableKernelModules = ["r8169"];

  # local network takes a while to connect to
  config.boot.initrd.network.udhcpc.extraArgs = ["--retries" "10"];

  # CA Derivations
  config.contentAddressedByDefault = true;

  # TODO FUTURE remove this it sets up the ethernet interface
  # https://github.com/NixOS/nixpkgs/issues/157034
  networking.interfaces.enp34s0.useDHCP = lib.mkDefault true;

  config.environment.systemPackages = with pkgs; [];

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
        openssh.authorizedKeys.keys = [(lib.removeSuffix "\n" (builtins.readFile (git_key_file_path + ".pub")))];
        shell = "${pkgs.git}/bin/git-shell";
      };
      user.openssh.authorizedKeys.keys = [(lib.removeSuffix "\n" (builtins.readFile (ssh_key_file_path + ".pub")))];
    };
  };
}
