# /bin/bash

# set -e 表示一旦脚本中有命令的返回值为非0，则脚本立即退出，后续命令不再执行
# set -o pipefail 表示在管道连接的命令序列中，只要有任何一个命令返回非0值，则整个管道返回非0值，即使最后一个命令返回0
set -e -o pipefail

# Git 配置
git_config()
{
	git config user.email 'yp_ren@hotmail.com'
	git config user.name  'yinping'
}

# 64位系统兼容32位应用包
DEB_X86_64="lib32z1 lib32ncurses5 lib32bz2-1.0 lib32stdc++6"
DEB_DEV_KIT="build-essential ccache bison flex automake intltool libncurses5-dev libssl-dev"
DEB_VER_CTRL="git subversion mercurial"
DEB_TOOLS="bash bash-completion vim unzip  gawk"

# 解包zip
# UNPACK_DIR 必须是完整目录路径
unpack_zip()
{
	DL_URL=$2
	UNPACK_DIR=$1
	DL_FILE=${DL_URL##*/};
	
	mkdir -p ${UNPACK_DIR%/*};
	pushd ${UNPACK_DIR%/*};
	if [ ! -d "${UNPACK_DIR}" ]; then
		if [ ! -f "${DL_FILE}" ]; then
			wget -O ${DL_FILE} ${DL_URL};
		fi;
		unzip -q ${DL_FILE};
		rm -rf ${DL_FILE};
	fi;
	popd;
}

# 解包tgz
# UNPACK_DIR 必须是完整目录路径
unpack_tgz()
{
	DL_URL=$2
	UNPACK_DIR=$1
	DL_FILE=${DL_URL##*/};
	
	mkdir -p ${UNPACK_DIR%/*};
	pushd ${UNPACK_DIR%/*};
	if [ ! -d "${UNPACK_DIR}" ]; then
		if [ ! -f "${DL_FILE}" ]; then
			wget -O ${DL_FILE} ${DL_URL};
		fi;
		tar -zxf ${DL_FILE};
		rm -rf ${DL_FILE};
	fi;
	popd;
}

# 解包tar.bz2
# UNPACK_DIR 必须是完整目录路径
unpack_tar_bz2()
{
	DL_URL=$2
	UNPACK_DIR=$1
	DL_FILE=${DL_URL##*/};
	
	mkdir -p ${UNPACK_DIR%/*};
	pushd ${UNPACK_DIR%/*};
	if [ ! -d "${UNPACK_DIR}" ]; then
		if [ ! -f "${DL_FILE}" ]; then
			wget -O ${DL_FILE} ${DL_URL};
		fi;
		tar -jxf ${DL_FILE};
		rm -rf ${DL_FILE};
	fi;
	popd;
}
