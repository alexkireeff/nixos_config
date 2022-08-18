{
  config,
  pkgs,
  lib,
  ...
}: {
# TODO current theory of errors:
# can't connect to initramfs bc incorrect ethernet module thingy
# can't connect to normal server bc iptables

# ssh setup
boot.initrd.network.enable = true;
boot.initrd.network.ssh = {
  enable = true;
  port = 22;
  authorizedKeys = config.users.users.user.openssh.authorizedKeys.keys;
  hostKeys = [ "/home/user/.ssh/initrd_ssh_host_key" ];
};

# copy your onion folder
boot.initrd.secrets = {
  "/etc/tor/onion/bootup" = /home/user/tor/onion; # maybe find a better spot to store this.
};

# copy tor to you initrd
boot.initrd.extraUtilsCommands = ''
  copy_bin_and_libs ${pkgs.tor}/bin/tor
'';

# start tor during boot process
boot.initrd.network.postCommands = let
  torRc = (pkgs.writeText "tor.rc" ''
    DataDirectory /etc/tor
    SOCKSPort 127.0.0.1:9050 IsolateDestAddr
    SOCKSPort 127.0.0.1:9063
    HiddenServiceDir /etc/tor/onion/bootup
    HiddenServicePort 22 127.0.0.1:22
  '');
in ''
  echo "tor: preparing onion folder"
  # have to do this otherwise tor does not want to start
  chmod -R 700 /etc/tor

  echo "make sure localhost is up"
  ip a a 127.0.0.1/8 dev lo
  ip link set lo up

  echo "tor: starting tor"
  tor -f ${torRc} --verify-config
  tor -f ${torRc} &
  ping 8.8.8.8
'';
}
