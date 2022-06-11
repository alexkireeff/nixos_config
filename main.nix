{ config, pkgs, lib, ... }:

let CD = builtins.toString ./.;

in {
  imports = [ "${CD}/boot.nix" "${CD}/packages.nix" "${CD}/services.nix" ];

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
      extraGroups = [ "wheel" "networkmanager" ];
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
