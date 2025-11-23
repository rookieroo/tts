#!/bin/bash

echo "🔍 检查服务状态..."

echo "----------------------------------------"
echo "1. F5-TTS (端口 7860)"
PID_F5=$(lsof -t -i:7860)
if [ -n "$PID_F5" ]; then
    echo "✅ 正在运行 (PID: $PID_F5)"
    ps -p $PID_F5 -o command= | cut -c 1-80
else
    echo "❌ 未运行"
fi

echo "----------------------------------------"
echo "2. IndexTTS (端口 7861)"
PID_INDEX=$(lsof -t -i:7861)
if [ -n "$PID_INDEX" ]; then
    echo "✅ 正在运行 (PID: $PID_INDEX)"
    ps -p $PID_INDEX -o command= | cut -c 1-80
else
    echo "❌ 未运行"
fi

echo "----------------------------------------"
echo "3. Cloudflare Tunnel"
PID_TUNNEL=$(pgrep -f "cloudflared tunnel run")
if [ -n "$PID_TUNNEL" ]; then
    echo "✅ 正在运行 (PID: $PID_TUNNEL)"
else
    echo "❌ 未运行"
fi
echo "----------------------------------------"
