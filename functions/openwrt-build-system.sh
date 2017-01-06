#!/bin/bash

# 安装工具包
openwrt_build_system_install()
{
	apt-get update \
	&& apt-get install -y \
	           lib32z1 lib32ncurses5 lib32bz2-1.0 lib32stdc++6 \
	           build-essential ccache \
	           libncurses5-dev libssl-dev \
	           git subversion mercurial \
	           screen tmux unzip gawk
	apt-get autoremove
	apt-get clean
}

# 使用全部128M NAND 空间
# TOP_DIR $1 OpenWrt Buildroot 构建根目录路径
wndr4300_nand128m()
{
	local OLD='wndr4300_mtdlayout=mtdparts=ar934x-nfc:256k(u-boot)ro,256k(u-boot-env)ro,256k(caldata),512k(pot),2048k(language),512k(config),3072k(traffic_meter),2048k(kernel),23552k(ubi),25600k@0x6c0000(firmware),256k(caldata_backup),-(reserved)'
	local NEW='wndr4300_mtdlayout=mtdparts=ar934x-nfc:256k(u-boot)ro,256k(u-boot-env)ro,256k(caldata),512k(pot),2048k(language),512k(config),3072k(traffic_meter),2048k(kernel),121856k(ubi),123904k@0x6c0000(firmware),256k(caldata_backup),-(reserved)'
	local EDIT_FILE='target/linux/ar71xx/image/Makefile'
	[ -n "$1" ] && local EDIT_FILE="$1/${EDIT_FILE}"
	
	[ ! -f "${EDIT_FILE}" ] && print_error "File not found: ${EDIT_FILE}" && return 1
	
#	sed -n  "/^${OLD}$/p" ${EDIT_FILE};
	sed -i "s/^${OLD}$/${NEW}/g" ${EDIT_FILE};
#	sed -n  "/^${NEW}$/p" ${EDIT_FILE};
	[ `sed -n  "/^${NEW}$/p" ${EDIT_FILE} | wc -l` -eq 1 ] && echo "WNDR4300/WNDR3700v4 NAND 128M OK."
}

# Image Builder 镜像生成器
image_build_system()
{
	# 无效参数
	[ -z "$1" ] && print_error "Missing parameters 1." && return 1
	local ARCH=$1
	
	[ -z "$2" ] && print_error "Missing parameters 2." && return 1
	local MD5=$2
	
	[ -z "$3" ] && print_error "Missing parameters 3." && return 1
	local DL_URL=$3
	
	local DL_SAVE=$4
	[ -z "$4" ] && local DL_SAVE=${DL_URL##*/}
	
	local TOP_DIR=$5
	[ -z "$5" ] && local TOP_DIR=${DL_SAVE%.tar.bz2} && local TOP_DIR=${TOP_DIR##*/}
	
	# DEBUG 
	print_debug "functions/openwrt-build-system.sh image_build_system $*"
	print_debug "ARCH=${ARCH}"
	print_debug "MD5=${MD5}"
	print_debug "DL_URL=${DL_URL}"
	print_debug "DL_SAVE=${DL_SAVE}"
	print_debug "TOP_DIR=${TOP_DIR} \n"
	# End
	
	mkdir -p ${ARCH}
	[ ! -d "${ARCH}/${TOP_DIR}" ] \
		&& download_md5 "${MD5}" "${DL_URL}" "${DL_SAVE}" \
		&& tar -jxf "${DL_SAVE}" -C ${ARCH}/
	
	ln -sf ${TOP_DIR} ${ARCH}/img
}
