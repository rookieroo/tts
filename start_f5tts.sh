#!/bin/bash
echo "🚀 启动 F5-TTS..."
export PATH="/opt/homebrew/bin:$PATH"
cd "$(dirname "$0")/F5-TTS"
source .venv/bin/activate

# 设置环境变量（必须在检查之前）
export HF_ENDPOINT=https://hf-mirror.com
export TORCHAUDIO_USE_BACKEND_DISPATCHER=1
export TORCHAUDIO_BACKEND=soundfile

# 检查是否已运行
if lsof -i:7860 > /dev/null; then
    echo "⚠️  F5-TTS 已经在运行中 (端口 7860)"
else
    # 启动并输出到终端，这样可以看到实时错误
    # 不要设置 root_path，让 Gradio 自动处理
    env HF_ENDPOINT=https://hf-mirror.com TORCHAUDIO_USE_BACKEND_DISPATCHER=1 TORCHAUDIO_BACKEND=soundfile \
        f5-tts_infer-gradio --port 7860 --host 0.0.0.0 2>&1 | tee f5tts.log &
    echo "✅ F5-TTS 已后台启动 (PID: $!)"
    echo "📄 日志文件: $(pwd)/f5tts.log"
fi
