{
  config,
  pkgs,
  lib,
  impure-info,
  ...
}: {
  boot.initrd = {
    # copy programs to initrd
    extraUtilsCommands = ''
      copy_bin_and_libs ${pkgs.bash}/bin/bash
      copy_bin_and_libs ${pkgs.pkgsStatic.curl}/bin/curl
    '';

    network = {
      enable = true;

      # after initrd done, run this command
      postCommands = ''
        curl --cacert /etc/ssl/certs/ca-certificates.crt "$(cat /etc/nixos/duckdns_url)" > /dev/null
      '';

      # ssh setup
      ssh = {
        enable = true;
        authorizedKeys = config.users.users.user.openssh.authorizedKeys.keys;
        hostKeys = [impure-info.initrd_ssh_host_key_file_path_string];
      };

      # make sure we connect to network
      udhcpc.extraArgs = ["--retries" "100"];
    };

    # copy files to initrd
    secrets = {
      "/etc/nixos/duckdns_url" = impure-info.duckdns_url_file_path_string;
      "/etc/ssl/certs/ca-certificates.crt" = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
    };
  };

  # update ddns every minute once decrypted
  systemd.services = {
    ddns-updater = {
      path = with pkgs; [
        bash
        pkgsStatic.curl
      ];
      script = "curl --cacert /etc/ssl/certs/ca-certificates.crt \"$(cat /etc/nixos/duckdns_url)\" > /dev/null";
      startAt = "minutely";
    };
  };
}
