#!/bin/bash

IFNAME="eth0"

IPV4_IP="{{ ansible_default_ipv4.address }}"
IPV4_MASK="{{ ansible_default_ipv4.netmask }}"
IPV4_GW="{{ ansible_default_ipv4.gateway }}"

IPV6_IP="{{ ansible_default_ipv6.address | default('none') }}/{{ ansible_default_ipv6.prefix | default('none')}}"
IPV6_GW="{{ ansible_default_ipv6.gateway | default('none') }}"

DNS="{{ ansible_dns.nameservers | default('8.8.8.8') | join(' ') }}"
SEARCH="{{ ansible_dns.search | default('example.org')| join(' ') }}"

cat > /etc/network/interfaces << EOM
auto lo
iface lo inet loopback

auto $IFNAME

iface $IFNAME inet static
  address $IPV4_IP
  netmask $IPV4_MASK
  gateway $IPV4_GW
EOM

if [ "{{ ansible_default_ipv6.address | default('') }}" ]; then
  cat >> /etc/network/interfaces << EOM
  iface $IFNAME inet6 static
    address $IPV6_IP_MASK
    gateway $IPV6_GW
    pre-up echo 0 > /proc/sys/net/ipv6/conf/$IFNAME/accept_ra
EOM
fi

echo '' > /etc/resolv.conf
for i in {{ ansible_dns.nameservers | default('8.8.8.8') | join(' ') }}; do
  echo "nameserver $i" >> /etc/resolv.conf
done

for i in {{ ansible_dns.search | default('8.8.8.8') | join(' ') }}; do
  echo "search $i" >> /etc/resolv.conf
done

mkdir -p /run/openrc
touch /run/openrc/softlevel
adduser -u 3000 --disabled-password "{{ ansible_user }}"
# # SoVeryHardToGuess!!! - to be changed anyway :D
echo '{{ ansible_user }}:$6$rDqX1oCGnJXeAGs0$opz1OPh0DKCjexItP6Ex9/fD5KlT2QXDB.J1uTe8dmjQAzKPkBwzmqoyGTjOzSS3phMQzm0xeYiYK8vV8YZKx0' | chpasswd -e
echo 'root:$6$rDqX1oCGnJXeAGs0$opz1OPh0DKCjexItP6Ex9/fD5KlT2QXDB.J1uTe8dmjQAzKPkBwzmqoyGTjOzSS3phMQzm0xeYiYK8vV8YZKx0' | chpasswd -e

echo "{{ ansible_user }} ALL=NOPASSWD: ALL" >> /etc/sudoers

mkdir -p /home/{{ ansible_user }}/.ssh
chown -R bt22 /home/{{ ansible_user }}

cat >> /etc/init.d/resize2fs << EOM
#! /sbin/openrc-run

description="resize2fs"

depend() {
  true
}
checkconfig() {
  true
}

command="/usr/sbin/resize2fs"
command_args="/dev/sda"
EOM
chmod a+x /etc/init.d/resize2fs

echo 
rc-update add resize2fs boot
rc-update add sshd default
rc-update add networking default


