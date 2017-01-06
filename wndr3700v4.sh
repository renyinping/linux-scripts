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

LUCI="luci luci-i18n-chinese"

img1407()
{
	local ARCH=ar71xx_nand_1407
	local MD5=67982a1cfd53133d692d2757a2285a4c
	local DL_URL=https://downloads.openwrt.org/barrier_breaker/14.07/ar71xx/nand/OpenWrt-ImageBuilder-ar71xx_nand-for-linux-x86_64.tar.bz2
	local DL_SAVE=dl/OpenWrt-ImageBuilder-ar71xx_nand-for-linux-x86_64.tar.bz2
	local TOP_DIR=OpenWrt-ImageBuilder-ar71xx_nand-for-linux-x86_64
	image_build_system ${ARCH} ${MD5} ${DL_URL} ${DL_SAVE} ${TOP_DIR}
	wndr4300_nand128m ${ARCH}/${TOP_DIR}
	
	local ALL="${LUCI}"
	
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
