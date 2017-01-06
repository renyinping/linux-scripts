#!/bin/sh

cd /
# 用户密码
BAK_LIST=etc/shadow

# 将配置文件添加到备份列表
add_list_cfg()
{
	[ -f "etc/config/$1" ] && BAK_LIST="${BAK_LIST} etc/config/$1"
}

add_list_cfg dhcp
#add_list_cfg dropbear
#add_list_cfg firewall
add_list_cfg fstab
add_list_cfg luci
add_list_cfg network
add_list_cfg polipo
add_list_cfg samba
add_list_cfg sslocal
add_list_cfg system
add_list_cfg transmission
add_list_cfg wireless

tar -zcvf /tmp/backup-openwrt.tar.gz ${BAK_LIST}
