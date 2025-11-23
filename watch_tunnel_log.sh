#!/bin/bash
echo "📊 实时查看 Cloudflare Tunnel 日志 (按 Ctrl+C 退出)"
echo "----------------------------------------"
tail -f ~/.cloudflared/tunnel.log
