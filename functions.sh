#!/bin/bash

alias  ls='ls --color=auto'
export LANG="zh_CN.UTF-8"
export LANGUAGE="zh_CN:en_US:en"

config_sudo()
{
	[ -n "$1" ] && local USER="$1"
	
	[ "${USER}" = "root" ] && return 0
	
	if (which sudo); then
		useradd -m -s /bin/bash ${USER}
		echo "${USER}:${USER}" | chpasswd
		echo "${USER} ALL=NOPASSWD: ALL" > /etc/sudoers.d/${USER}
		chmod 440 /etc/sudoers.d/${USER}
		echo "Configure sudo to complete."
	fi
}

config_git()
{
	if (which git); then
		git config --global user.name  'yinping'
		git config --global user.email 'yp_ren@hotmail.com'
		git config --global color.ui true
		git config --global core.autocrlf input
		echo "Configure git to complete."
	fi
}

config_locales()
{
	if (which locale-gen); then
		sed -i 's/# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/g' /etc/locale.gen
		sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
		locale-gen
		echo "Configure locales to complete."
	fi
}

config()
{
	[ -z "$*" ] && return 0
	
	for i in $*; do
		case $i in
			dropbear)           echo "root:root" | chpasswd;;
			locale-gen|locales) config_locales;;
			git)                config_git;;
			sudo)               ;;
			*)                  ;;
		esac
	done
}

install()
{
	[ -z "$*" ] && return 0
	
	for i in $*; do
		echo Adding $i ...
		case $i in
			dropbear)           local DEB_LIST="${DEB_LIST} dropbear openssh-sftp-server vim" ;;
			locale-gen|locales) local DEB_LIST="${DEB_LIST} locales" ;;
			git)                local DEB_LIST="${DEB_LIST} git-core bash-completion vim" ;;
			sudo)               local DEB_LIST="${DEB_LIST} sudo" ;;
			vim)                local DEB_LIST="${DEB_LIST} vim" ;;
			*)                  ;;
		esac
	done
	
	[ -z "${DEB_LIST}" ] && return 0
	echo "Install list: ${DEB_LIST}"
	
	apt-get update || return 1
	apt-get install -y ${DEB_LIST}
	
	config $*
}
