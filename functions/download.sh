#!/bin/bash

#. print.sh

# 下载
# DL_URL  文件链接
# DL_SAVE 保存文件名,建议包含路径
download()
{
	[ -z "$1" ] && print_error "Missing parameters." && return 1
	local DL_URL=$1
	
	local DL_SAVE=$2
	[ -z "$2" ] && local DL_SAVE=${DL_URL##*/}
	
	# 当变量“${DL_SAVE}”中不含“/”时，会导致“${DL_SAVE%/*}”出错
	#local DL_DIR=${DL_SAVE%/*}
	#
	# 解决方法：
	#    1. 先在“${DL_SAVE}”前添加一个“/”
	#    2. 正常截取“/”前的子串，即目录部分
	#    3. 从位置“1”开始提取子串，丢弃之前额外添加的“/”
	#local DL_DIR=/${DL_SAVE} && local DL_DIR=${DL_DIR%/*} && local DL_DIR=${DL_DIR:1}
	#[ -n "${DL_DIR}" ] && mkdir -p "${DL_DIR}"
	#
	# 解决方法2：
	local DL_DIR=${DL_SAVE%/*}
	[ -n "${DL_DIR}" ] && [ "${DL_DIR}" != "${DL_SAVE}" ] && mkdir -p "${DL_DIR}"
	
	# DEBUG
	print_debug "functions/download.sh download $*"
	print_debug "DL_URL=${DL_URL}"
	print_debug "DL_SAVE=${DL_SAVE}"
	print_debug "DL_DIR=${DL_DIR} \n"
	# End
	
	# 文件已存在
	[ -f "${DL_SAVE}" ] && print_warning "The file already exists." && return 0;
	
	wget -O ${DL_SAVE} ${DL_URL}
}

# 下载并校验
# MD5 MD5值
download_md5()
{
	# 无效参数
	[ -z "$1" ] && print_error "Missing parameters 1." && return 1
	local MD5=$1
	
	[ -z "$2" ] && print_error "Missing parameters 2." && return 1
	local DL_URL=$2
	
	local DL_SAVE=$3
	[ -z "$3" ] && local DL_SAVE=${DL_URL##*/}
	
	# DEBUG 
	print_debug "functions/download.sh download_md5 $*"
	print_debug "MD5=${MD5}"
	print_debug "DL_URL=${DL_URL}"
	print_debug "DL_SAVE=${DL_SAVE} \n"
	# End
	
	[ -f "${DL_SAVE}" ] \
		&& hash_md5 ${MD5} ${DL_SAVE} \
		&& return 0
	
	rm -rf ${DL_SAVE}
	download ${DL_URL} ${DL_SAVE} \
		&& hash_md5 ${MD5} ${DL_SAVE} \
		&& return 0
	
	# 下载失败
	print_error "download failed (${DL_URL})."
	return 1
}
