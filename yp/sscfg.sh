#!/bin/sh ./common

CFGCNT=${0%/*}/sscfg.cnt
CFGTXT=${0%/*}/sscfg.txt
CFGHTML=/tmp/sscfg.html

# 获取配置数据 $1=配置数据索引
get_cfg()
{
	[ -z $1 ] && return 1
	[ $1 -lt 0 ] && return 1
	local n=$1
	
	server=`sed -n "$((n*4+1))p" ${CFGTXT}`
	server_port=`sed -n "$((n*4+2))p" ${CFGTXT}`
	key=`sed -n "$((n*4+3))p" ${CFGTXT}`
	method=`sed -n "$((n*4+4))p" ${CFGTXT}`
	print_ok "get configure $1"
	
	echo "server      = $server"
	echo "server_port = $server_port"
	echo "key         = $key"
	echo "method      = $method"
	return 0
}

# 设置nvram
set_nvram()
{
	if [ -z "$1" ]
	then
		[ ! -f "$CFGCNT" ] && echo "0" > "$CFGCNT"
		local n=`cat "$CFGCNT"`
		local n=$((n+1))
		[ "$n" -ge 5 ] && n=0
		echo "$n" > "$CFGCNT"
	else
		local n=$1
	fi
	
	get_cfg $n
	nvram set ss_server=$server
	nvram set ss_server_port=$server_port
	nvram set ss_key=$key
	nvram set ss_method=$method
	nvram set ss_server1=$server
	nvram set ss_s1_port=$server_port
	nvram set ss_s1_key=$key
	nvram set ss_s1_method=$method
	nvram commit
	
	if [ -z "$2" ]
	then
		local n=$((n+5))
	else
		local n=$2
	fi
	
	get_cfg $n
	nvram set ss_server2=$server
	nvram set ss_s2_port=$server_port
	nvram set ss_s2_key=$key
	nvram set ss_s2_method=$method
	nvram commit
	
	return 0
}

# 更新配置数据文本
__update_cfgtxt()
{
	IPv4_Segment="\(25[0-5]\|2[0-4][0-9]\|[01]\?[0-9]\?[0-9]\)"
	IPv4="\(\(25[0-5]\|2[0-4][0-9]\|[01]\?[0-9]\?[0-9]\)\.\)"
	IPv4="${IPv4}\{3\}"
	IPv4="${IPv4}\(25[0-5]\|2[0-4][0-9]\|[01]\?[0-9]\?[0-9]\)"
	sed -n "/<td>${IPv4}<\/td>/{p;{n;p};{n;p};{n;p}}" ${CFGHTML} > ${CFGTXT}
	sed -i "s/<[\/]\?td>//g" ${CFGTXT}
	sed -i "s/ //g"          ${CFGTXT}
	print_ok "update ${CFGTXT##*/}"
	return 0
}

# 更新
update()
{
	# 获取网页并更新配置文本
	local CFGURL=$1
	download $CFGURL $CFGHTML
	print_result $? "Download $CFGHTML" && __update_cfgtxt
	rm -rf ${CFGHTML}
}

# 重启ss
restart()
{
	set_nvram
	/tmp/ss.sh start
}
