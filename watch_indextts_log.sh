#!/bin/bash
echo "📊 实时查看 IndexTTS 日志 (按 Ctrl+C 退出)"
echo "----------------------------------------"
tail -f "$(dirname "$0")/index-tts/indextts.log"
