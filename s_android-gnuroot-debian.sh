#!/bin/bash

# ls彩色输出
ls_color()
{
	[ `cat /etc/bash.bashrc | sed -n '/^alias ls=/p' | wc -l` -eq 0 ] \
		&& echo "alias ls='ls --color=auto'" >> /etc/bash.bashrc
}

# 安装
install()
{
	[ `which dropbear` ] || local DEB_LIST="dropbear openssh-sftp-server vim"
	[ `which git` ]      || local DEB_LIST="${DEB_LIST} git-core bash-completion"
	
	[ -z "${DEB_LIST}" ] && return 0
	
	apt-get update || return 1
	apt-get install -y ${DEB_LIST}
	
	if [ `which git` ]; then
		git config --global user.name  'yinping'
		git config --global user.email 'yp_ren@hotmail.com'
		git config --global color.ui true
		git config --global core.autocrlf input
	fi
}

# 启动ssh服务
sshd_start()
{
	[ `ps -ef | sed -n '/dropbear -p 2022$/p' | wc -l` -eq 0 ] \
		&& dropbear -p 2022 \
		&& sleep 3
	
	ps -ef | sed -n '/dropbear -p 2022$/p'
}

ls_color
install
sshd_start
