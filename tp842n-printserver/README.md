# TP842Nv3 打印服务器固件项目

## 项目简介
为TP842Nv3 (AR9531芯片)路由器定制的OpenWrt固件，集成CUPS 2.4.2中文打印服务，支持HP LaserJet系列打印机。

## 主要功能
- 基于OpenWrt 22.03稳定版，固件大小控制在16MB以内
- 集成CUPS 2.4.2中文打印服务
- 预装HP LaserJet 1020/1020plus/1007/1008/1108驱动
- USB打印机即插即用支持
- 每日定时重启功能
- 中文LuCI管理界面
- 固定网络配置

## 默认配置
- LAN IP: 192.168.10.1
- Web管理: admin / thdn12345678
- WiFi SSID: THDN-dayin / 密码: thdn12345678
- 主机名: THDN-PrintServer

## 构建环境
- Ubuntu 22.04 LTS
- OpenWrt 22.03 SDK
- 一键编译脚本

## 