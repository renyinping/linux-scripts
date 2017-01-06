#?/bin/bash

PATH=`dirname $(readlink -f $0)`/functions:$PATH
. print.sh
. hash.sh
. download.sh
. openwrt-build-system.sh

install()
{
	openwrt_build_system_install
}

# 软件仓库
repositories_conf()
{
	# 缺少参数
	[ -z "$1" ] && print_error "Missing parameters 1." && return 1
	local ARCH=$1
	
	local FILE="${ARCH}/img/repositories.conf"
	[ ! -f "${FILE}" ] && print_error "File not found: ${FILE}" && return 1
	
	echo '# Place your custom repositories here, they must match the architecture and version.
# src/gz barrier_breaker http://downloads.openwrt.org/barrier_breaker/14.07/ar71xx/nand/packages
# src custom file:///usr/src/openwrt/bin/ar71xx/packages
src/gz barrier_breaker_base https://downloads.openwrt.org/barrier_breaker/14.07/ar71xx/nand/packages/base
src/gz barrier_breaker_luci https://downloads.openwrt.org/barrier_breaker/14.07/ar71xx/nand/packages/luci
src/gz barrier_breaker_packages https://downloads.openwrt.org/barrier_breaker/14.07/ar71xx/nand/packages/packages
src/gz barrier_breaker_routing https://downloads.openwrt.org/barrier_breaker/14.07/ar71xx/nand/packages/routing
src/gz barrier_breaker_telephony https://downloads.openwrt.org/barrier_breaker/14.07/ar71xx/nand/packages/telephony
src/gz barrier_breaker_management https://downloads.openwrt.org/barrier_breaker/14.07/ar71xx/nand/packages/management
src/gz barrier_breaker_oldpackages https://downloads.openwrt.org/barrier_breaker/14.07/ar71xx/nand/packages/oldpackages
## This is the local package repository, do not remove!
src imagebuilder file:packages' > ${FILE}
}

# 使用全部128M NAND 空间
# TOP_DIR $1 OpenWrt Buildroot 构建根目录路径
wndr4300_nand128m()
{
	# 缺少参数
	[ -z "$1" ] && print_error "Missing parameters 1." && return 1
	local ARCH=$1
	
	local FILE="${ARCH}/img/target/linux/ar71xx/image/Makefile"
	[ ! -f "${FILE}" ] && print_error "File not found: ${FILE}" && return 1
	
	local OLD='wndr4300_mtdlayout=mtdparts=ar934x-nfc:256k(u-boot)ro,256k(u-boot-env)ro,256k(caldata),512k(pot),2048k(language),512k(config),3072k(traffic_meter),2048k(kernel),23552k(ubi),25600k@0x6c0000(firmware),256k(caldata_backup),-(reserved)'
	local NEW='wndr4300_mtdlayout=mtdparts=ar934x-nfc:256k(u-boot)ro,256k(u-boot-env)ro,256k(caldata),512k(pot),2048k(language),512k(config),3072k(traffic_meter),2048k(kernel),121856k(ubi),123904k@0x6c0000(firmware),256k(caldata_backup),-(reserved)'
	
#	sed -n  "/^${OLD}$/p"        ${FILE};
	sed -i "s/^${OLD}$/${NEW}/g" ${FILE};
#	sed -n  "/^${NEW}$/p"        ${FILE};
	[ `sed -n  "/^${NEW}$/p" ${FILE} | wc -l` -eq 1 ] && echo "WNDR4300/WNDR3700v4 NAND 128M OK."
}

# 配置文件
files()
{
	# 缺少参数
	[ -z "$1" ] && print_error "Missing parameters 1." && return 1
	local ARCH=$1
	
	local FILES_DIR=${ARCH}/img/files
	local BAK_FILE=backup-openwrt.tar.gz
	
	# DEBUG 
	print_debug "wndr3700v4.sh files $*"
	print_debug "ARCH=${ARCH}"
	# End
	
	[ -f "${BAK_FILE}" ] \
		&& mkdir -p "${FILES_DIR}" \
		&& tar -zxvf "${BAK_FILE}" -C "${FILES_DIR}/"
}

files_rm()
{
	# 缺少参数
	[ -z "$1" ] && print_error "Missing parameters 1." && return 1
	local ARCH=$1
	
	rm -rf ${ARCH}/img/files/ \
		&& echo "The deletion is complete."
}

img1407()
{
	local ARCH=ar71xx_nand_1407
	local MD5=67982a1cfd53133d692d2757a2285a4c
	local DL_URL=https://downloads.openwrt.org/barrier_breaker/14.07/ar71xx/nand/OpenWrt-ImageBuilder-ar71xx_nand-for-linux-x86_64.tar.bz2
	local DL_SAVE=dl/OpenWrt-ImageBuilder-ar71xx_nand-for-linux-x86_64.tar.bz2
	local TOP_DIR=OpenWrt-ImageBuilder-ar71xx_nand-for-linux-x86_64
	image_build_system ${ARCH} ${MD5} ${DL_URL} ${DL_SAVE} ${TOP_DIR}
	wndr4300_nand128m ${ARCH}
	repositories_conf ${ARCH}
	
	# packages
	local LUCI="luci luci-i18n-chinese"
	local TOOLS="wget ca-certificates unzip zip unrar tar bash bash-completion hdparm bind-dig"
	local USB="kmod-usb-storage block-mount usbutils blkid fdisk"
	local EXT4="e2fsprogs kmod-fs-ext4 kmod-nls-utf8"
	local FAT32="kmod-fs-vfat kmod-nls-cp437 kmod-nls-iso8859-1"
	local SMB="luci-app-samba"
	local BT="transmission-daemon luci-app-transmission transmission-web"
	local SS="shadowsocks-client polipo"
	local XXNET="python python-openssl pyopenssl wget ca-certificates unzip bash"
	local ALL="$LUCI $TOOLS $USB $EXT4 $FAT32 $SMB $BT $SS $XXNET"
	
	# make image
	pushd ${ARCH}/img
	if [ -d "files" ]; then
		make image PROFILE=WNDR4300 PACKAGES="${ALL}" FILES=files
	else
		make image PROFILE=WNDR4300 PACKAGES="${ALL}"
	fi
	popd
}


################################################################
if [ -z "$1" ]; then
	cat $0 | grep \(\)$
else
	if [ `cat $0 | grep ^$1\(\)$ | wc -l` -eq 1 ]; then
		$*
	else
		echo "Invalid parameter"
	fi
fi
