#!/bin/bash
# THDN打印服务器环境设置脚本

set -e

echo "=== THDN打印服务器环境设置 ==="

# 检查运行环境
if [ "$(id -u)" -ne 0 ]; then
    echo "错误: 需要root权限运行此脚本"
    exit 1
fi

# 创建必要的目录
mkdir -p /var/log/cups
mkdir -p /var/spool/cups
mkdir -p /var/spool/cups/tmp
mkdir -p /var/spool/cups/cache
mkdir -p /tmp/printer_status

# 设置权限
chmod 755 /var/log/cups
chmod 755 /var/spool/cups
chmod 1777 /var/spool/cups/tmp
chmod 755 /tmp/printer_status

# 创建CUPS用户和组
if ! grep -q "^cups:" /etc/group; then
    echo "创建CUPS组..."
    echo "cups:x:100:cups" >> /etc/group
fi

if ! grep -q "^cups:" /etc/passwd; then
    echo "创建CUPS用户..."
    echo "cups:x:100:100:CUPS User:/var/spool/cups:/bin/false" >> /etc/passwd
fi

# 配置USB打印机支持
echo "配置USB打印机支持..."
if [ -f /etc/modules.d/usb-printer ]; then
    echo "usb-printer" >> /etc/modules.d/usb-printer
fi

# 启用服务
echo "启用必要的服务..."
/etc/init.d/cups enable
/etc/init.d/cron enable
/etc/init.d/hotplug2 enable

# 设置防火墙规则（如果存在）
if [ -f /etc/config/firewall ]; then
    echo "配置防火墙规则..."
    uci add firewall rule
    uci set firewall.@rule[-1].name='Allow-CUPS'
    uci set firewall.@rule[-1].src='lan'
    uci set firewall.@rule[-1].proto='tcp'
    uci set firewall.@rule[-1].dest_port='631'
    uci set firewall.@rule[-1].target='ACCEPT'
    uci commit firewall
fi

# 创建打印机状态文件
echo "USB打印机未连接" > /tmp/printer_status

echo "环境设置完成!"
echo "请重启系统或手动启动服务:"
echo "  /etc/init.d/cups start"
echo "  /etc/init.d/cron start"
