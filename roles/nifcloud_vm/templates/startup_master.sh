#!/bin/sh

# Description:CentOS 7.1 64bit Plain Cloud Init Script for NiftyCloud (http://cloud.nifty.com/)
# 2017/12/8 @Con_H

(
#===============================================
# Settings
#===============================================
##rootのパスワード
ROOT_PASSWORD='{root_password}'
#===============================================
ARC=$(/bin/uname -m)
SALT=$(/usr/bin/uuidgen| /usr/bin/tr -d '-')

## hostname変更
HOSTNAME=$(/usr/bin/vmtoolsd --cmd 'info-get guestinfo.hostname')
/bin/hostname ${{HOSTNAME}}
/bin/sed -i.org -e 's/localhost.localdomain/'${{HOSTNAME}}'/' /etc/hostname

## ROOTパスワード設定
/usr/sbin/usermod -p $(/usr/bin/perl -e 'print crypt(${{ARGV[0]}}, ${{ARGV[1]}})' ${{ROOT_PASSWORD}} ${{SALT}}) root

## swap領域 無効化
/usr/sbin/swapoff `awk '{{print $1}}' /proc/swaps | grep -v 'Filename'`
/usr/bin/sed -i -e "/swap/s/^/#/g" /etc/fstab

## network 設定
IPADDR={ip_addr}
CONNECTION="System ens192"
NETWORK_ADDR={network_addr}
GATEWAY={gateway}
/usr/bin/nmcli connection modify "${{CONNECTION}}" ipv4.addresses ${{IPADDR}}
/usr/bin/nmcli connection modify "${{CONNECTION}}" ipv4.gateway ${{GATEWAY}}
/usr/bin/nmcli connection modify "${{CONNECTION}}" ipv4.dns ${{GATEWAY}}
/usr/bin/nmcli connection modify "${{CONNECTION}}" ipv4.method manual
/usr/bin/nmcli connection down "${{CONNECTION}}"
/usr/bin/nmcli connection up "${{CONNECTION}}"
/bin/systemctl restart NetworkManager.service
/bin/systemctl restart network.service
) 2>&1 | /usr/bin/tee /var/log/niftycloud-init.log
