#!/bin/bash

# 设置ls彩色输出
set_ls()
{
	[ `cat /etc/bash.bashrc | sed -n '/^alias ls=/p' | wc -l` -eq 0 ] \
		&& echo "alias ls='ls --color=auto'" >> /etc/bash.bashrc
}

# 设置语言
set_locale()
{
	if [ `which locale-gen` ]; then
		sed -i 's/# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/g' /etc/locale.gen
		sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
		[ `cat /etc/bash.bashrc | sed -n '/^LANG=/p' | wc -l` -eq 0 ] \
			&& echo 'LANG="zh_CN.UTF-8"' >> /etc/bash.bashrc
		[ `cat /etc/bash.bashrc | sed -n '/^LANGUAGE=/p' | wc -l` -eq 0 ] \
			&& echo 'LANGUAGE="zh_CN:en_US:en"' >> /etc/bash.bashrc
	fi
}

# 设置sudo
set_sudo()
{
	if [ `which sudo` ]; then
		useradd -m -s /bin/bash debian
		echo 'debian:debian' | chpasswd
		echo 'debian ALL=NOPASSWD: ALL' > /etc/sudoers.d/debian
		chmod 440 /etc/sudoers.d/debian
	fi
}

# 设置git
set_git()
{
	if [ `which git` ]; then
		git config --global user.name  'yinping'
		git config --global user.email 'yp_ren@hotmail.com'
		git config --global color.ui true
		git config --global core.autocrlf input
	fi
}

# 安装
install()
{
	[ `which sudo` ]       || local DEB_LIST="sudo"
	[ `which locale-gen` ] || local DEB_LIST="${DEB_LIST} locales" 
	[ `which dropbear` ]   || local DEB_LIST="${DEB_LIST} dropbear openssh-sftp-server vim"
	[ `which git` ]        || local DEB_LIST="${DEB_LIST} git-core bash-completion"
	
	[ -z "${DEB_LIST}" ] && return 0
	
	apt-get update || return 1
	apt-get install -y ${DEB_LIST}
	
	set_ls
	set_locale
	set_sudo
	set_git
}

# 启动ssh服务
start_sshd()
{
	if [ `ps -ef | sed -n '/dropbear -p 2022$/p' | wc -l` -eq 0 ]; then
		dropbear -p 2022
		sleep 3
	else
		install
	fi
	
	ps -ef | sed -n '/dropbear -p 2022$/p'
	echo ""
}

################################################################
if [ -z "$1" ]; then
	start_sshd
	cat $0 | grep \(\)$
else
	if [ `cat $0 | grep ^$1\(\)$ | wc -l` -eq 1 ]; then
		$*
	else
		echo "Invalid parameter"
	fi
fi
