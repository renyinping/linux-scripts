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

# Image Builder 镜像生成器
image_build_system()
{
	# 缺少参数
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
