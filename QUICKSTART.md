# 🚀 快速启动指南

## 一键操作

```bash
# 启动所有服务
./restart_services.sh

# 停止所有服务
./stop_services.sh

# 检查状态
./check_status.sh
```

## 访问地址

### 本地访问
- **F5-TTS**: http://localhost:7860
- **IndexTTS**: http://localhost:7861

### 远程访问
- **F5-TTS**: https://f5tts.example.com
- **IndexTTS**: https://indextts.example.com

## 查看日志

```bash
# 实时查看 F5-TTS 日志
./watch_f5tts_log.sh

# 实时查看 IndexTTS 日志
./watch_indextts_log.sh

# 实时查看 Tunnel 日志
./watch_tunnel_log.sh
```

## 常见问题

### 服务无法启动？
```bash
# 1. 检查端口是否被占用
lsof -i :7860
lsof -i :7861

# 2. 查看错误日志
cat F5-TTS/f5tts.log
cat index-tts/indextts.log

# 3. 重启服务
./restart_services.sh
```

### 文件上传失败？
确认 Gradio 版本是 5.44.0：
```bash
cd F5-TTS
source .venv/bin/activate
pip show gradio | grep Version
```

如果不是，执行：
```bash
pip install "gradio==5.44.0"
./restart_services.sh
```

### Tunnel 连接失败？
```bash
# 检查 Tunnel 状态
cloudflared tunnel info tts-tunnel

# 查看 Tunnel 日志
cat tunnel.log
```

## 更多帮助

详细文档请参阅 `README.md`
