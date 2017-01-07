#?/bin/bash

PATH=`dirname $(readlink -f $0)`/functions:$PATH
. print.sh
. hash.sh
. download.sh
. openwrt-build-system.sh

ARCH=ar71xx_nand_1407

install()
{
	openwrt_build_system_install
}

# 软件仓库
repo()
{
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
nand128m()
{
	local FILE="${ARCH}/img/target/linux/ar71xx/image/Makefile"
	[ ! -f "${FILE}" ] && print_error "File not found: ${FILE}" && return 1
	
	local OLD='wndr4300_mtdlayout=mtdparts=ar934x-nfc:256k(u-boot)ro,256k(u-boot-env)ro,256k(caldata),512k(pot),2048k(language),512k(config),3072k(traffic_meter),2048k(kernel),23552k(ubi),25600k@0x6c0000(firmware),256k(caldata_backup),-(reserved)'
	local NEW='wndr4300_mtdlayout=mtdparts=ar934x-nfc:256k(u-boot)ro,256k(u-boot-env)ro,256k(caldata),512k(pot),2048k(language),512k(config),3072k(traffic_meter),2048k(kernel),121856k(ubi),123904k@0x6c0000(firmware),256k(caldata_backup),-(reserved)'
	
#	sed -n  "/^${OLD}$/p"        ${FILE};
	sed -i "s/^${OLD}$/${NEW}/g" ${FILE};
#	sed -n  "/^${NEW}$/p"        ${FILE};
	[ `sed -n  "/^${NEW}$/p" ${FILE} | wc -l` -eq 1 ] && echo "WNDR4300/WNDR3700v4 NAND 128M OK."
}

# 构建环境
img_sys()
{
	local MD5=67982a1cfd53133d692d2757a2285a4c
	local DL_URL=https://downloads.openwrt.org/barrier_breaker/14.07/ar71xx/nand/OpenWrt-ImageBuilder-ar71xx_nand-for-linux-x86_64.tar.bz2
	local DL_SAVE=dl/OpenWrt-ImageBuilder-ar71xx_nand-for-linux-x86_64.tar.bz2
	local TOP_DIR=OpenWrt-ImageBuilder-ar71xx_nand-for-linux-x86_64
	image_build_system ${ARCH} ${MD5} ${DL_URL} ${DL_SAVE} ${TOP_DIR}
	nand128m
	repo
}

# clean
clean()
{
	pushd ${ARCH}/img
	rm -rf files/ 
	make clean
	popd
}

# 解包备份文件
files()
{
	mkdir -p ${ARCH}/img/files
	tar -zxvf backup-openwrt.tar.gz -C ${ARCH}/img/files/
}

# 构建镜像
img()
{
	# 包列表
	local LUCI="luci luci-i18n-chinese"
	local TOOLS="wget ca-certificates unzip zip unrar tar bash bash-completion hdparm bind-dig"
	local USB="kmod-usb-storage block-mount usbutils blkid fdisk"
	local EXT4="e2fsprogs kmod-fs-ext4 kmod-nls-utf8"
	local FAT32="kmod-fs-vfat kmod-nls-cp437 kmod-nls-iso8859-1"
	local SMB="luci-app-samba"
	local BT="transmission-daemon luci-app-transmission transmission-web"
	local SS="shadowsocks-client polipo"
	local XXNET="python python-openssl pyopenssl wget ca-certificates unzip bash"
	
	# 基础包和全功能包选择
	if [ "$1" = "base" ]; then
		local IPK_LIST="$LUCI -kmod-usb-core -kmod-usb-ohci -kmod-usb2"
	else
		local IPK_LIST="$LUCI $TOOLS $USB $EXT4 $FAT32 $SMB $BT $SS $XXNET"
	fi
	
	# make
	pushd ${ARCH}/img
	if [ -d "files" ]; then
		make image PROFILE=WNDR4300 PACKAGES="${IPK_LIST}" FILES=files
	else
		make image PROFILE=WNDR4300 PACKAGES="${IPK_LIST}"
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
