# F5-TTS 源码补丁说明

## 📋 补丁清单

我们对上游 F5-TTS 代码做了以下修改，用于解决兼容性问题：

### 1. torchaudio Backend 修复

**问题**: macOS Apple Silicon 上 torchcodec 0.8.1 加载失败
**影响文件**:
- `src/f5_tts/infer/infer_gradio.py`
- `src/f5_tts/infer/utils_infer.py`

**修改内容**:
```python
# 在文件开头添加（import 之前）
os.environ.setdefault("TORCHAUDIO_USE_BACKEND_DISPATCHER", "1")
os.environ.setdefault("TORCHAUDIO_BACKEND", "soundfile")

# 修改所有 torchaudio.load() 调用
# 修改前:
audio, sr = torchaudio.load(ref_audio)
# 修改后:
audio, sr = torchaudio.load(ref_audio, backend="soundfile")
```

**原因**: 强制使用 soundfile 后端替代有问题的 torchcodec

### 2. Gradio 配置优化

**问题**: 文件上传限制和错误显示
**影响文件**: `src/f5_tts/infer/infer_gradio.py`

**修改内容**:
```python
# 在 main() 函数的 app.launch() 中添加:
app.queue(api_open=api).launch(
    server_name=host,
    server_port=port,
    share=share,
    show_api=api,
    root_path=root_path,
    inbrowser=inbrowser,
    max_file_size="100mb",        # 新增
    allowed_paths=["/tmp"],        # 新增
    show_error=True,               # 新增
)
```

**原因**: 提高文件上传限制，允许临时文件访问

## 🔄 更新上游代码流程

### 方案 A：手动更新（推荐）

```bash
cd /Users/mond/Desktop/tts/F5-TTS

# 1. 查看当前修改
git status
git diff > ../f5tts_local_changes.patch

# 2. 暂存你的修改
git stash

# 3. 拉取上游更新
git pull origin main

# 4. 重新应用你的修改
git stash pop

# 5. 如果有冲突，手动解决
# 然后运行补丁脚本确保所有修改都在
cd ..
./apply_patches.sh

# 6. 测试
./restart_services.sh
```

### 方案 B：使用补丁文件

```bash
# 1. 创建补丁文件（首次）
cd /Users/mond/Desktop/tts/F5-TTS
git diff > ../f5tts.patch

# 2. 重置代码
git reset --hard origin/main

# 3. 拉取更新
git pull origin main

# 4. 应用补丁
git apply ../f5tts.patch

# 5. 如果失败，使用我们的脚本
cd ..
./apply_patches.sh
```

### 方案 C：Fork 仓库（长期方案）

1. 在 GitHub 上 Fork `SWivid/F5-TTS`
2. 克隆你的 Fork:
   ```bash
   cd /Users/mond/Desktop/tts
   rm -rf F5-TTS
   git clone https://github.com/YOUR_USERNAME/F5-TTS.git
   ```
3. 创建补丁分支:
   ```bash
   cd F5-TTS
   git checkout -b macos-fixes
   # 应用所有修改
   ../apply_patches.sh
   git add .
   git commit -m "fix: macOS Apple Silicon compatibility"
   git push origin macos-fixes
   ```
4. 更新时:
   ```bash
   git fetch upstream
   git rebase upstream/main
   git push origin macos-fixes --force
   ```

## 📦 导出当前补丁

```bash
cd /Users/mond/Desktop/tts/F5-TTS
git diff > ../patches/f5tts-macos-compat.patch
```

保存这个文件，以后更新时可以直接 `git apply`

## 🔍 验证补丁是否生效

```bash
# 检查环境变量设置
grep -n "TORCHAUDIO_BACKEND" src/f5_tts/infer/infer_gradio.py
grep -n "TORCHAUDIO_BACKEND" src/f5_tts/infer/utils_infer.py

# 检查 backend 参数
grep -n 'backend="soundfile"' src/f5_tts/infer/infer_gradio.py
grep -n 'backend="soundfile"' src/f5_tts/infer/utils_infer.py

# 检查 Gradio 配置
grep -n "max_file_size" src/f5_tts/infer/infer_gradio.py
```

## 🐛 如果更新后出问题

```bash
# 回退到上一个工作版本
cd /Users/mond/Desktop/tts/F5-TTS
git log --oneline -10  # 找到之前的 commit
git reset --hard <commit-hash>

# 重新安装
cd /Users/mond/Desktop/tts
./stop_services.sh
cd F5-TTS
source .venv/bin/activate
pip install -e .
pip install "gradio==5.44.0"
cd ..
./start_f5tts.sh
```

## 💡 最佳实践建议

1. **定期备份当前工作版本**
   ```bash
   cd /Users/mond/Desktop/tts
   tar -czf backups/f5tts-$(date +%Y%m%d).tar.gz F5-TTS/
   ```

2. **记录每次更新**
   - 更新前的版本号: `git log -1 --oneline`
   - 更新后的版本号
   - 是否需要重新应用补丁
   - 测试结果

3. **测试清单**
   - [ ] 服务能否启动
   - [ ] 文件上传是否正常
   - [ ] 音频生成是否工作
   - [ ] 无 torchcodec 错误

4. **版本锁定**
   如果某个版本很稳定，可以：
   ```bash
   cd F5-TTS
   git tag stable-$(date +%Y%m%d)
   git push origin stable-$(date +%Y%m%d)
   ```

## 📝 修改历史

- **2025-11-23**: 初始补丁创建
  - 添加 torchaudio soundfile backend 强制使用
  - 修复 torchcodec 兼容性
  - 优化 Gradio 配置
