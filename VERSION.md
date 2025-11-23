# 项目版本信息

## 版本记录

- **项目版本**: 1.0.0
- **创建日期**: 2025年11月23日
- **最后更新**: 2025年11月23日

## 软件版本

| 组件 | 版本 | 备注 |
|------|------|------|
| Python | 3.11.14_1 | Homebrew 安装 |
| F5-TTS | 1.1.9 | Editable 模式安装 |
| Gradio | 5.44.0 | ⚠️ 锁定版本（避免 upload bug） |
| PyTorch | 2.9.1 | Apple Silicon 优化 |
| torchaudio | 2.9.1 | Apple Silicon 优化 |
| IndexTTS | Latest | 从 GitHub 克隆 |
| cloudflared | Latest | Homebrew 安装 |
| ffmpeg | Latest | Homebrew 安装 |

## 关键配置

### F5-TTS
- **端口**: 7860
- **主机**: 0.0.0.0
- **虚拟环境**: `<PROJECT_ROOT>/F5-TTS/.venv`
- **日志文件**: `F5-TTS/f5tts.log`

### IndexTTS
- **端口**: 7861
- **主机**: 0.0.0.0
- **虚拟环境**: `<PROJECT_ROOT>/index-tts/.venv`
- **日志文件**: `index-tts/indextts.log`

### Cloudflare Tunnel
- **Tunnel ID**: <YOUR_TUNNEL_ID>
- **配置文件**: `~/.cloudflared/config.yml`
- **日志文件**: `tunnel.log`

## 域名配置

- `f5tts.example.com` → localhost:7860
- `indextts.example.com` → localhost:7861

## 环境变量

### F5-TTS 启动环境
```bash
PATH="/opt/homebrew/bin:$PATH"
HF_ENDPOINT=https://hf-mirror.com
TORCHAUDIO_BACKEND=soundfile
TORCHAUDIO_USE_BACKEND_DISPATCHER=1
```

### IndexTTS 启动环境
```bash
PATH="/opt/homebrew/bin:$PATH"
HF_ENDPOINT=https://hf-mirror.com
```

## 已知问题

1. **Gradio 5.50.0 upload bug** - 已通过降级到 5.44.0 解决
2. **torchcodec 加载失败** - 已通过环境变量强制使用 soundfile 解决
3. **HF 下载超时** - 已配置镜像站 hf-mirror.com

## 更新记录

### 2025-11-23
- ✅ 初始版本发布
- ✅ 完成 F5-TTS 和 IndexTTS 部署
- ✅ 配置 Cloudflare Tunnel
- ✅ 修复 Gradio upload_id=undefined 问题
- ✅ 创建管理脚本和文档
