#!/bin/bash

# 检查参数数量
if [ "$#" -ne 2 ]; then
    echo "用法: $0 <端口号> <时间（分钟）>"
    exit 1
fi

PORT=$1
TIME_MINUTES=$2
TIME_SECONDS=$((TIME_MINUTES * 60))

# 检测操作系统并确定使用的防火墙
if command -v ufw >/dev/null 2>&1; then
    FIREWALL="ufw"
elif command -v firewall-cmd >/dev/null 2>&1; then
    FIREWALL="firewalld"
else
    echo "未检测到支持的防火墙 (ufw 或 firewalld)"
    exit 1
fi

# 开放端口
if [ "$FIREWALL" = "ufw" ]; then
    sudo ufw allow "$PORT"
    sudo ufw reload
    echo "端口 $PORT 已使用 ufw 开放"
elif [ "$FIREWALL" = "firewalld" ]; then
    sudo firewall-cmd --zone=public --add-port="$PORT"/tcp --permanent
    sudo firewall-cmd --reload
    echo "端口 $PORT 已使用 firewalld 开放"
fi

# 睡眠指定时间
sleep "$TIME_SECONDS"

# 关闭端口
if [ "$FIREWALL" = "ufw" ]; then
    sudo ufw deny "$PORT"
    sudo ufw reload
    echo "端口 $PORT 已使用 ufw 关闭"
elif [ "$FIREWALL" = "firewalld" ]; then
    sudo firewall-cmd --zone=public --remove-port="$PORT"/tcp --permanent
    sudo firewall-cmd --reload
    echo "端口 $PORT 已使用 firewalld 关闭"
fi
