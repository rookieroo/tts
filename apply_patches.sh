#!/bin/bash
# F5-TTS 补丁应用脚本
# 用于在更新上游代码后重新应用我们的修改

set -e

cd "$(dirname "$0")/F5-TTS"

echo "🔧 应用 F5-TTS 补丁..."

# 补丁 1: 修复 torchaudio backend (infer_gradio.py)
echo "📝 修补 src/f5_tts/infer/infer_gradio.py..."

# 在文件开头添加环境变量设置（如果还没有）
if ! grep -q "TORCHAUDIO_BACKEND" src/f5_tts/infer/infer_gradio.py; then
    # 在 import 之前插入环境变量设置
    sed -i.bak '10a\
# Set torchaudio backend BEFORE importing torchaudio to avoid torchcodec issues\
os.environ.setdefault("TORCHAUDIO_USE_BACKEND_DISPATCHER", "1")\
os.environ.setdefault("TORCHAUDIO_BACKEND", "soundfile")\
' src/f5_tts/infer/infer_gradio.py
fi

# 修改 torchaudio.load 调用
sed -i.bak 's/torchaudio\.load(f\.name)/torchaudio.load(f.name, backend="soundfile")/g' src/f5_tts/infer/infer_gradio.py

# 补丁 2: 修复 torchaudio backend (utils_infer.py)
echo "📝 修补 src/f5_tts/infer/utils_infer.py..."

if ! grep -q "TORCHAUDIO_BACKEND" src/f5_tts/infer/utils_infer.py; then
    sed -i.bak '7a\
# Set torchaudio backend BEFORE importing to avoid torchcodec issues\
os.environ.setdefault("TORCHAUDIO_USE_BACKEND_DISPATCHER", "1")\
os.environ.setdefault("TORCHAUDIO_BACKEND", "soundfile")\
' src/f5_tts/infer/utils_infer.py
fi

sed -i.bak 's/torchaudio\.load(ref_audio)/torchaudio.load(ref_audio, backend="soundfile")/g' src/f5_tts/infer/utils_infer.py

# 补丁 3: 添加 Gradio 配置
if ! grep -q "max_file_size" src/f5_tts/infer/infer_gradio.py; then
    echo "📝 添加 Gradio 配置..."
    # 这个需要手动应用，因为位置比较特殊
    cat << 'EOF'
⚠️  需要手动添加以下配置到 main() 函数的 app.launch():
    max_file_size="100mb",
    allowed_paths=["/tmp"],
    show_error=True,
EOF
fi

# 清理备份文件
rm -f src/f5_tts/infer/*.bak

echo "✅ 补丁应用完成！"
echo ""
echo "📋 应用的补丁："
echo "  1. ✅ torchaudio backend 强制使用 soundfile"
echo "  2. ✅ 修复 torchcodec 兼容性问题"
echo "  3. ⚠️  Gradio 配置（需手动验证）"
echo ""
echo "💡 提示：如果遇到问题，请查看 PATCHES.md 了解详细说明"
