#!/bin/bash
echo "🚀 启动 IndexTTS..."
export PATH="/opt/homebrew/bin:$PATH"
cd /Users/mond/Desktop/tts/index-tts
source .venv/bin/activate

# 检查是否已运行
if lsof -i:7861 > /dev/null; then
    echo "⚠️  IndexTTS 已经在运行中 (端口 7861)"
else
    export HF_ENDPOINT=https://hf-mirror.com
    nohup python webui.py --port 7861 --host 0.0.0.0 > indextts.log 2>&1 &
    echo "✅ IndexTTS 已后台启动 (PID: $!)"
    echo "📄 日志文件: /Users/mond/Desktop/tts/index-tts/indextts.log"
fi
