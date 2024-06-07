# `manage_port.sh` 使用说明

## 简介

`manage_port.sh` 是一个用于在 Linux 系统上临时开放并随后关闭指定端口的脚本。该脚本接受端口号和时间（以分钟为单位）作为参数，并根据系统自动检测使用 `ufw` 或 `firewalld` 防火墙来管理端口的开放和关闭。

## 使用方法

### 前提条件

- Linux 系统
- 安装并启用 `ufw` 或 `firewalld`
- 用户具备执行 `sudo` 命令的权限

### 脚本内容

```sh
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

# 睡眠并在后台运行关闭端口命令
{
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
} &

echo "后台进程启动成功，脚本将在 $TIME_MINUTES 分钟后自动关闭端口 $PORT。"

```
保存和运行脚本
将上述脚本内容保存为 manage_port.sh 文件：

``` sh

nano manage_port.sh
```
给脚本添加可执行权限：

``` sh

chmod +x manage_port.sh
```
运行脚本，传入端口号和时间（以分钟为单位）作为参数：

``` sh

./manage_port.sh <端口号> <时间（分钟）>
```
例如，若要开放端口 8080 并在 5 分钟后关闭它，可以运行：

``` sh

./manage_port.sh 8080 5
```
示例
假设你想要开放端口 8080 并在 5 分钟后关闭它：

``` sh

./manage_port.sh 8080 5

```
脚本输出：

``` yaml

端口 8080 已使用 ufw 开放
（5 分钟后）
端口 8080 已使用 ufw 关闭
或（使用 firewalld）：
```
``` yaml

端口 8080 已使用 firewalld 开放
（5 分钟后）
端口 8080 已使用 firewalld 关闭
```
注意事项
请确保你有权限运行 sudo 命令。
请确保系统中已经安装并启用了 ufw 或 firewalld 防火墙工具。
在生产环境中使用此脚本时，请注意安全性，确保只有授权用户可以执行该脚本。
许可
## 本脚本按 MIT 许可证分发。有关详细信息，请参阅 LICENSE 文件。
