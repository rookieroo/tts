#!/bin/bash
echo "📊 实时查看 F5-TTS 日志 (按 Ctrl+C 退出)"
echo "----------------------------------------"
tail -f "$(dirname "$0")/F5-TTS/f5tts.log"
