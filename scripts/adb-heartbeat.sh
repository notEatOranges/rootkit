#!/usr/bin/env bash
# adb-heartbeat.sh —— PC 侧轻量保活心跳(A/B 实验用,**未验证**,n=2 观察引发的假设)
#
# 背景:2026-10-29 BKQ-AN10 上,唯一一轮开着本脚本式轻量轮询的链(20s 间隔只读命令)
# 三连命中 0 panic;但无监听的昨天也全链成功过 ⇒ 只是「值得 A/B 的假设」,不是结论。
# 实验方案见 logsnapshots/2026-10-29-BKQ-AN10/研究笔记-adb监听与命中.md §5。
#
# 用法: bash adb-heartbeat.sh [间隔秒=20] [adb serial 可空]
# 停止: Ctrl+C
set -u
IV=${1:-20}
ADB="/d/Program Files/Android-SDK/Sdk/platform-tools/adb.exe"
if [ $# -ge 2 ]; then ADB="$ADB -s $2"; fi
LOG="${3:-$PWD/heartbeat-$(date +%Y%m%d-%H%M%S).log}"
echo "adb 心跳: 每 ${IV}s 一条只读命令;打点 → $LOG (Ctrl+C 停止)"
while true; do
  TS=$(date +%H:%M:%S)
  OUT=$("$ADB" shell 'getenforce 2>/dev/null | tr -d "\r"; cut -d. -f1 /proc/uptime 2>/dev/null | tr -d "\r"' 2>&1)
  if [ -z "$OUT" ] || echo "$OUT" | command grep -qE "no devices|offline|error"; then
    echo "[$TS] ✗ 设备无响应(可能 panic 重启中)" | tee -a "$LOG"
  else
    echo "[$TS] ok $(echo "$OUT" | tr '\n' ' ')" | tee -a "$LOG"
  fi
  sleep "$IV"
done
