#!/bin/bash
echo "🛑 停止服务..."

echo "正在停止 F5-TTS..."
pkill -f f5-tts_infer-gradio
if [ $? -eq 0 ]; then echo "✅ F5-TTS 已停止"; else echo "⚠️  F5-TTS 未运行或无法停止"; fi

echo "正在停止 IndexTTS..."
pkill -f "webui.py --port 7861"
if [ $? -eq 0 ]; then echo "✅ IndexTTS 已停止"; else echo "⚠️  IndexTTS 未运行或无法停止"; fi

echo "正在停止 Cloudflare Tunnel..."
pkill -f cloudflared
if [ $? -eq 0 ]; then echo "✅ Tunnel 已停止"; else echo "⚠️  Tunnel 未运行或无法停止"; fi
