{
  config,
  pkgs,
  lib,
  ...
}: {
  # ssh setup
  boot.initrd.network.enable = false;
  boot.initrd.network.ssh = {
    enable = true;
    port = 22;
    authorizedKeys = config.users.users.user.openssh.authorizedKeys.keys;
    hostKeys = ["/home/user/.ssh/initrd_ssh_host_key"];
  };

  # copy files to initrd
  boot.initrd.secrets = {
    "/etc/nixos/duckdnsurl" = null;
    "/etc/ssl/certs/ca-certificates.crt" = null;
  };

  # copy programs to initrd
  boot.initrd.extraUtilsCommands = ''
    copy_bin_and_libs ${pkgs.bash}/bin/bash
    copy_bin_and_libs ${pkgs.pkgsStatic.curl}/bin/curl
  '';

  # run during boot process
  boot.initrd.network.postCommands = ''
    echo "starting duckdns ip updating script"
    nohup watch -n 60 curl --cacert /etc/ssl/certs/ca-certificates.crt "$(cat /etc/nixos/duckdnsurl)" > /dev/null &
    echo "script started successfully"
  '';

  systemd.services = {
    ddns-updater = {
      path = with pkgs; [
        bash
        pkgsStatic.curl
      ];
      script = "curl --cacert /etc/ssl/certs/ca-certificates.crt \"$(cat /etc/nixos/duckdnsurl)\" > /dev/null";
      startAt = "minutely";
    };
  };
}
