#!/bin/bash
echo "🚀 启动 Cloudflare Tunnel..."

# 检查是否已运行
if pgrep -f "cloudflared tunnel run" > /dev/null; then
    echo "⚠️  Cloudflare Tunnel 已经在运行中"
else
    nohup cloudflared tunnel run TTS > ~/.cloudflared/tunnel.log 2>&1 &
    echo "✅ Cloudflare Tunnel 已后台启动 (PID: $!)"
    echo "📄 日志文件: ~/.cloudflared/tunnel.log"
fi
