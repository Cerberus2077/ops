#!/bin/bash
mv /etc/sysconfig/network-scripts/ifcfg-em2 /etc/sysconfig/network-scripts/ifcfg-em2.bak
mv /etc/sysconfig/network-scripts/ifcfg-em1 /etc/sysconfig/network-scripts/ifcfg-em1.bak
echo "# Broadcom Corporation Netxtreme II BCM5709 Gigabit Ethernet" >> /etc/sysconfig/network-scripts/ifcfg-em2
echo "DEVICE=em2" >> /etc/sysconfig/network-scripts/ifcfg-em2
echo "BOOTPROTO=none" >> /etc/sysconfig/network-scripts/ifcfg-em2
echo "ONBOOT=yes" >> /etc/sysconfig/network-scripts/ifcfg-em2
echo "MASTER=bond0" >> /etc/sysconfig/network-scripts/ifcfg-em2
echo "SLAVE=yes" >> /etc/sysconfig/network-scripts/ifcfg-em2
echo "USERCTL=no" >> /etc/sysconfig/network-scripts/ifcfg-em2

echo "# Broadcom Corporation Netxtreme II BCM5709 Gigabit Ethernet" >> /etc/sysconfig/network-scripts/ifcfg-em1
echo "DEVICE=em1" >> /etc/sysconfig/network-scripts/ifcfg-em1
echo "BOOTPROTO=none" >> /etc/sysconfig/network-scripts/ifcfg-em1
echo "ONBOOT=yes" >> /etc/sysconfig/network-scripts/ifcfg-em1
echo "MASTER=bond0" >> /etc/sysconfig/network-scripts/ifcfg-em1
echo "SLAVE=yes" >> /etc/sysconfig/network-scripts/ifcfg-em1
echo "USERCTL=no" >> /etc/sysconfig/network-scripts/ifcfg-em1

echo -n "Please input IP address:"
read IPADR
echo -n "Please input Netmask:"
read NTMK
echo -n "Please input Gateway:"
read GTWY
echo "DEVICE=bond0" >> /etc/sysconfig/network-scripts/ifcfg-bond0
echo "IPADDR=$IPADR" >> /etc/sysconfig/network-scripts/ifcfg-bond0
echo "NETMASK=$NTMK" >> /etc/sysconfig/network-scripts/ifcfg-bond0
echo "GATEWAY=$GTWY" >> /etc/sysconfig/network-scripts/ifcfg-bond0
echo "ONBOOT=yes" >> /etc/sysconfig/network-scripts/ifcfg-bond0
echo "BOOTPROTO=static" >> /etc/sysconfig/network-scripts/ifcfg-bond0
echo "BONDING_MASTER=yes" >> /etc/sysconfig/network-scripts/ifcfg-bond0
echo "BONDING_SLAVE0=em2" >> /etc/sysconfig/network-scripts/ifcfg-bond0
echo "BONDING_SLAVE1=em1" >> /etc/sysconfig/network-scripts/ifcfg-bond0
echo "BONDING_MODULE_OPTS=\"mode=1\ miimon=100\"" >> /etc/sysconfig/network-scripts/ifcfg-bond0
echo "DNS1=119.29.29.29" >> /etc/sysconfig/network-scripts/ifcfg-bond0

echo "alias bond0 bonding" >> /etc/modprobe.conf
echo "options bond0 miimon=100 mode=1" >> /etc/modprobe.conf

service network stop
service network start
ping $GTWY
