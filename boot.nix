{ config, pkgs, lib, ... }:

{

  # TODO FUTURE use btrfs if stable (or zfs if it gets a more permissive license)

  boot.kernelPackages = pkgs.linuxPackages_hardened;

  boot.kernelModules = [ "tcp_bbr" ];

  # TODO put more security stuff in here
  boot.kernel.sysctl = {
    # Disable SysRq key
    "kernel.sysrq" = 0;
    # Ignore ICMP broadcasts
    "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
    # Ignore bad ICMP errors
    "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
    # Reverse path filter for spoof protection
    "net.ipv4.conf.default.rp_filter" = 1;
    "net.ipv4.conf.all.rp_filter" = 1;
    # SYN flood protection
    "net.ipv4.tcp_syncookies" = 1;
    # Don't accept ICMP redirects (MITM attacks)
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    # Or secure redirects
    "net.ipv4.conf.all.secure_redirects" = 0;
    "net.ipv4.conf.default.secure_redirects" = 0;
    # Or on ipv6
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;
    # Do not send ICMP redirects (we not hacker)
    "net.ipv4.conf.all.send_redirects" = 0;
    # Do not accept IP source route packets (we not router)
    "net.ipv4.conf.all.accept_source_route" = 0;
    "net.ipv6.conf.all.accept_source_route" = 0;
    # Protect against tcp time wait assasination hazards
    "net.ipv4.tcp_rfc1337" = 1;
    # Latency reduction
    "net.ipv4.tcp_fastopen" = 3;
    ## Bufferfloat mitigations
    # Requires >= 4.9 & kernel module
    "net.ipv4.tcp_congestion_control" = "bbr";
    # Set network stack scheduler
    "net.core.default_qdisc" = "cake";
  };

}
