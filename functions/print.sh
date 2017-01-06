#!/bin/bash

# 错误信息
print_error()
{
	echo -e "\033[31m  Error: $1 \033[0m"
}

# 警告信息
print_warning()
{
	echo -e "\033[33m  Warning: $1 \033[0m"
}

# 调试信息
# 使用 export DEBUG=1 开启调试信息
# 使用 export DEBUG=0 关闭调试信息
print_debug()
{
	[ "${DEBUG}" ] || return
	[ "${DEBUG}" -eq 0 ] && return
	echo -e "\033[32m  Debug: $1 \033[0m"
}
