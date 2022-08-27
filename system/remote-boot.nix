{
  config,
  pkgs,
  lib,
  ...
}: {
  # ssh setup
  boot.initrd.network.enable = true;
  boot.initrd.network.ssh = {
    enable = true;
    port = 22;
    authorizedKeys = config.users.users.user.openssh.authorizedKeys.keys;
    hostKeys = ["/home/user/.ssh/initrd_ssh_host_key"];
  };

  # copy files to initrd
  boot.initrd.secrets = {
    "/etc/nixos/duckdnsscript.sh" = null;
    "/etc/ssl/certs/ca-certificates.crt" = null;
  };

  # copy programs to initrd
  boot.initrd.extraUtilsCommands = ''
    copy_bin_and_libs ${pkgs.bash}/bin/bash
    copy_bin_and_libs ${pkgs.pkgsStatic.curl}/bin/curl
  '';

  # run during boot process
  boot.initrd.network.postCommands = ''
    echo "updating duckdns ip"
    bash /etc/nixos/duckdnsscript.sh
  '';

  systemd.services = {
    ddns-updater= {
      path = with pkgs; [
        bash
        pkgsStatic.curl
      ];
      script = "bash /etc/nixos/duckdnsscript.sh";
      startAt = "minutely";
    };
  };
}
