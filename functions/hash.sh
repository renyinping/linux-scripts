#!/bin/bash

# MD5检查
# MD5 MD5值
# FILE 需要检查的文件
hash_md5()
{
	[ -z "$1" ] && print_error "Missing parameters 1." && return 1
	local MD5=$1
	
	[ -z "$2" ] && print_error "Missing parameters 2." && return 1
	local FILE=$2
	
	# DEBUG 
	print_debug "functions/hash.sh hash_md5 $*"
	print_debug "MD5=${MD5}"
	print_debug "FILE=${FILE} \n"
	# End
	
	# 该文件不存在
	[ ! -f "${FILE}" ] && print_error "The file does not exist." && return 1;
	
	local MD5_TMP=`md5sum ${FILE}`
	local MD5_TMP=${MD5_TMP%%\ *}
	echo "${MD5_TMP} ${FILE}"
	
	if [ "${MD5}" = "${MD5_TMP}" ]; then
		return 0
	else
		return 1
	fi
}
