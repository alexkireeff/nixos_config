{
  config,
  pkgs,
  lib,
  ...
}: {
  # TODO make variables for the file paths

  # initrd ssh setup
  boot.initrd.network.enable = true;
  boot.initrd.network.ssh = {
    enable = true;
    port = 22;
    authorizedKeys = config.users.users.user.openssh.authorizedKeys.keys;
    # TODO settings?
    hostKeys = ["/etc/tor/initrd/initrd_ssh_host_key"];
  };

  # initrd copy secrets
  boot.initrd.secrets = {
    "/etc/tor/onion/bootup" =
      if (builtins.pathExists /home/user/tor/onion)
      then /home/user/tor/onion
      else throw "no initrd onion file";
    "/etc/tor/initrd/initrd_ssh_host_key" =
      if (builtins.pathExists /home/user/.ssh/initrd_ssh_host_key)
      then /home/user/.ssh/initrd_ssh_host_key
      else throw "no initrd ssh file";
  };

  # initrd copy tor, haveged, ntpupdate
  boot.initrd.extraUtilsCommands = ''
    copy_bin_and_libs ${pkgs.tor}/bin/tor
    copy_bin_and_libs ${pkgs.haveged}/bin/haveged
    copy_bin_and_libs ${pkgs.ntp}/bin/ntpdate
  '';

  # run tor during boot process
  # TODO does this keep on running tor? idk
  boot.initrd.network.postCommands = let
    torrc = pkgs.writeText "tor.rc" ''
      DataDirectory /etc/tor
      SOCKSPort 127.0.0.1:9050 IsolateDestAddr
      SOCKSPort 127.0.0.1:9063
      HiddenServiceDir /etc/tor/onion/bootup
      HiddenServicePort 22 127.0.0.1:22
    '';
  in ''
    # tor needs 700 on folder
    chmod -R 700 /etc/tor

    # TODO necessary?
    ip a a 127.0.0.1/8 dev lo
    ip link set lo up

    ntpupdate 0.north-america.pool.ntp.org

    haveged -F &

    tor -f ${torrc} --verify-config
    tor -f ${torrc} &
  '';

}
