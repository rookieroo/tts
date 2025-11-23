# 本地 TTS 服务部署方案

> 基于 F5-TTS 和 IndexTTS 的本地语音合成服务，通过 Cloudflare Tunnel 实现安全的远程访问

## 📋 项目初衷

在 AI 语音合成（TTS）领域，虽然有许多优秀的开源模型（如 F5-TTS、IndexTTS），但要将它们部署为可靠的服务并实现安全的远程访问，仍然面临诸多挑战：

1. **本地部署复杂**：需要配置 Python 环境、依赖管理、模型下载等
2. **远程访问困难**：传统方案需要公网 IP、端口转发、防火墙配置
3. **安全性问题**：直接暴露服务端口存在安全风险
4. **服务管理不便**：缺少统一的启动、停止、监控脚本
5. **版本兼容性**：不同版本的库存在 bug，需要版本锁定

本项目旨在提供一套**开箱即用**的解决方案，让开发者能够：
- ✅ 快速部署 TTS 服务到本地 macOS 设备
- ✅ 通过 Cloudflare Tunnel 实现零配置的安全远程访问
- ✅ 使用简单的脚本管理多个服务
- ✅ 避免常见的版本兼容性问题

## 🎯 设计思路

### 架构设计

```
┌─────────────────────────────────────────────────────────────┐
│                       互联网用户                              │
└────────────────────┬────────────────────────────────────────┘
                     │ HTTPS
                     ▼
┌─────────────────────────────────────────────────────────────┐
│              Cloudflare Network (CDN + Security)             │
│  ┌─────────────────────┐  ┌─────────────────────────────┐  │
│  │ f5tts.propsdin.com  │  │ indextts.propsdin.com       │  │
│  └──────────┬──────────┘  └──────────┬──────────────────┘  │
└─────────────┼──────────────────────────┼─────────────────────┘
              │ Encrypted Tunnel         │
              ▼                          ▼
┌─────────────────────────────────────────────────────────────┐
│                    本地 macOS 设备                            │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Cloudflare Tunnel Daemon                            │   │
│  │  (cloudflared)                                       │   │
│  └────┬────────────────────────────────────┬───────────┘   │
│       │ localhost:7860                     │ localhost:7861│
│       ▼                                    ▼               │
│  ┌─────────────────┐              ┌──────────────────┐    │
│  │   F5-TTS        │              │   IndexTTS       │    │
│  │   (Gradio 5.44) │              │   (WebUI)        │    │
│  │   Python 3.11   │              │   Python 3.10    │    │
│  └─────────────────┘              └──────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

### 核心设计原则

1. **简单优先**：使用脚本封装复杂操作，提供一键启动/停止能力
2. **安全第一**：通过 Cloudflare Tunnel 避免暴露端口，支持身份验证
3. **稳定可靠**：锁定经过验证的软件版本，避免兼容性问题
4. **易于维护**：提供状态监控、日志查看等运维工具
5. **文档完善**：记录所有已知问题和解决方案

### 技术选型

| 组件 | 技术选型 | 选择理由 |
|------|---------|---------|
| TTS 模型 | F5-TTS 1.1.9 + IndexTTS | F5-TTS 零样本能力强，IndexTTS 中文效果好 |
| Python 版本 | 3.11.14 (Homebrew) | 兼容性好，性能优秀 |
| Web 框架 | Gradio 5.44.0 | 快速构建 UI，但需锁定版本避免 upload bug |
| 远程访问 | Cloudflare Tunnel | 零配置、免费、安全性高 |
| 进程管理 | Shell 脚本 + nohup | 简单可靠，无需额外依赖 |
| 包管理 | pip + venv | 传统方案，兼容性最好（弃用 uv） |

## 🚀 实现教程

### 前置条件

- macOS (Apple Silicon 或 Intel)
- Homebrew 包管理器
- Cloudflare 账号（免费版即可）
- 一个已配置 DNS 的域名

### 步骤 1：安装系统依赖

```bash
# 安装 Homebrew（如果还没有）
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 安装必要软件
brew install python@3.11 ffmpeg cloudflared git
```

### 步骤 2：克隆项目

```bash
cd ~/Desktop
mkdir tts && cd tts

# 克隆 F5-TTS
git clone https://github.com/SWivid/F5-TTS.git

# 克隆 IndexTTS
git clone https://github.com/indexxlabs/index-tts.git
```

### 步骤 3：配置 F5-TTS

```bash
cd F5-TTS

# 创建虚拟环境（使用 Python 3.11）
/opt/homebrew/bin/python3.11 -m venv .venv
source .venv/bin/activate

# 安装 PyTorch（Apple Silicon 优化版）
pip install torch torchaudio

# 安装 F5-TTS（注意：会锁定 Gradio 5.44.0）
pip install -e .

# 重要：降级 Gradio 到稳定版本（避免 upload_id=undefined bug）
pip install "gradio==5.44.0"
```

### 步骤 4：配置 IndexTTS

```bash
cd ../index-tts

# IndexTTS 使用系统 Python 或创建独立环境
python3 -m venv .venv
source .venv/bin/activate

# 安装依赖
pip install -r requirements.txt  # 或按项目文档安装
```

### 步骤 5：配置 Cloudflare Tunnel

```bash
# 登录 Cloudflare
cloudflared tunnel login

# 创建 Tunnel
cloudflared tunnel create tts-tunnel

# 记录 Tunnel ID（类似：71aebf4a-5e2e-4754-9d0a-d2832f85f0c8）
```

创建配置文件 `~/.cloudflared/config.yml`：

```yaml
tunnel: <YOUR_TUNNEL_ID>
credentials-file: /Users/<YOUR_USERNAME>/.cloudflared/<YOUR_TUNNEL_ID>.json

ingress:
  # F5-TTS 服务
  - hostname: f5tts.propsdin.com
    service: http://localhost:7860
    originRequest:
      connectTimeout: 300s
      keepAliveTimeout: 300s
      tcpKeepAlive: 300s
      noTLSVerify: false
      disableChunkedEncoding: true
  
  # IndexTTS 服务
  - hostname: indextts.propsdin.com
    service: http://localhost:7861
    originRequest:
      connectTimeout: 300s
      keepAliveTimeout: 300s
      tcpKeepAlive: 300s
      noTLSVerify: false
      disableChunkedEncoding: true
  
  # 默认规则
  - service: http_status:404
```

配置 DNS（在 Cloudflare Dashboard）：

```bash
# 添加 CNAME 记录
f5tts.propsdin.com    CNAME   <YOUR_TUNNEL_ID>.cfargotunnel.com
indextts.propsdin.com CNAME   <YOUR_TUNNEL_ID>.cfargotunnel.com
```

### 步骤 6：创建管理脚本

返回 `~/Desktop/tts` 目录，创建以下脚本：

#### `start_f5tts.sh`
```bash
#!/bin/bash
cd "$(dirname "$0")/F5-TTS"
export PATH="/opt/homebrew/bin:$PATH"
export HF_ENDPOINT=https://hf-mirror.com
export TORCHAUDIO_BACKEND=soundfile
export TORCHAUDIO_USE_BACKEND_DISPATCHER=1

echo "🚀 启动 F5-TTS..."
nohup .venv/bin/f5-tts_infer-gradio \
    --port 7860 \
    --host 0.0.0.0 \
    > f5tts.log 2>&1 &
    
echo "✅ F5-TTS 已后台启动 (PID: $!)"
echo "📄 日志文件: $(pwd)/f5tts.log"
```

#### `start_indextts.sh`
```bash
#!/bin/bash
cd "$(dirname "$0")/index-tts"
export PATH="/opt/homebrew/bin:$PATH"
export HF_ENDPOINT=https://hf-mirror.com

echo "🚀 启动 IndexTTS..."
nohup python webui.py --port 7861 --host 0.0.0.0 \
    > indextts.log 2>&1 &
    
echo "✅ IndexTTS 已后台启动 (PID: $!)"
echo "📄 日志文件: $(pwd)/indextts.log"
```

#### `start_tunnel.sh`
```bash
#!/bin/bash
cd "$(dirname "$0")"

echo "🚀 启动 Cloudflare Tunnel..."
nohup cloudflared tunnel run tts-tunnel \
    > tunnel.log 2>&1 &
    
echo "✅ Cloudflare Tunnel 已后台启动 (PID: $!)"
echo "📄 日志文件: $(pwd)/tunnel.log"
```

#### `stop_services.sh`
```bash
#!/bin/bash
echo "🛑 停止所有服务..."

pkill -f "f5-tts_infer-gradio"
pkill -f "webui.py"
pkill -f "cloudflared tunnel"

echo "✅ 所有服务已停止"
```

#### `restart_services.sh`
```bash
#!/bin/bash
cd "$(dirname "$0")"

echo "🔄 重启所有服务..."
./stop_services.sh
sleep 2
./start_tunnel.sh
sleep 1
./start_f5tts.sh
./start_indextts.sh
echo "✅ 所有服务已重启"
```

#### `check_status.sh`
```bash
#!/bin/bash
echo "🔍 检查服务状态..."
echo "----------------------------------------"

echo "1. F5-TTS (端口 7860)"
if pgrep -f "f5-tts_infer-gradio" > /dev/null; then
    echo "✅ 正在运行 (PID: $(pgrep -f 'f5-tts_infer-gradio'))"
    ps aux | grep "[f]5-tts_infer-gradio" | awk '{print $11, $12, $13, $14, $15}'
else
    echo "❌ 未运行"
fi

echo "----------------------------------------"
echo "2. IndexTTS (端口 7861)"
if pgrep -f "webui.py" > /dev/null; then
    echo "✅ 正在运行 (PID: $(pgrep -f 'webui.py'))"
    ps aux | grep "[w]ebui.py" | awk '{print $11, $12, $13, $14, $15}'
else
    echo "❌ 未运行"
fi

echo "----------------------------------------"
echo "3. Cloudflare Tunnel"
if pgrep -f "cloudflared tunnel" > /dev/null; then
    echo "✅ 正在运行 (PID: $(pgrep -f 'cloudflared tunnel'))"
else
    echo "❌ 未运行"
fi
echo "----------------------------------------"
```

#### `watch_f5tts_log.sh`
```bash
#!/bin/bash
tail -f "$(dirname "$0")/F5-TTS/f5tts.log"
```

#### `watch_indextts_log.sh`
```bash
#!/bin/bash
tail -f "$(dirname "$0")/index-tts/indextts.log"
```

#### `watch_tunnel_log.sh`
```bash
#!/bin/bash
tail -f "$(dirname "$0")/tunnel.log"
```

赋予执行权限：

```bash
chmod +x *.sh
```

### 步骤 7：启动服务

```bash
# 启动所有服务
./start_tunnel.sh    # 先启动 Tunnel
./start_f5tts.sh     # 启动 F5-TTS
./start_indextts.sh  # 启动 IndexTTS

# 检查状态
./check_status.sh

# 查看日志
./watch_f5tts_log.sh     # Ctrl+C 退出
```

### 步骤 8：访问服务

- **本地访问**：
  - F5-TTS: http://localhost:7860
  - IndexTTS: http://localhost:7861

- **远程访问**：
  - F5-TTS: https://f5tts.propsdin.com
  - IndexTTS: https://indextts.propsdin.com

## 📚 已知问题与解决方案

### 1. Gradio upload_id=undefined 错误

**问题**：Gradio 5.50.0 存在文件上传 bug，表现为 `upload_id=undefined`

**解决方案**：降级到 Gradio 5.44.0
```bash
cd F5-TTS
source .venv/bin/activate
pip install "gradio==5.44.0"
```

**详细文档**：`UPLOAD_ID_UNDEFINED_FIX.md`

### 2. torchcodec 加载失败

**问题**：Apple Silicon 上可能遇到 `RuntimeError: Could not load libtorchcodec`

**解决方案**：强制使用 soundfile 后端
```bash
export TORCHAUDIO_BACKEND=soundfile
export TORCHAUDIO_USE_BACKEND_DISPATCHER=1
```

已在 `start_f5tts.sh` 中配置，无需手动设置。

### 3. Hugging Face 下载超时

**问题**：国内访问 huggingface.co 经常超时

**解决方案**：使用镜像站
```bash
export HF_ENDPOINT=https://hf-mirror.com
```

已在启动脚本中配置。

### 4. Cloudflare Workers 身份验证

如果你的域名配置了 Cloudflare Workers 身份验证，需要为 Gradio API 路径添加白名单：

- `/gradio_api/*`
- `/queue/*`
- `/file/*`
- `/upload/*`
- `/api/*`

### 5. uv 包管理器兼容性问题

**不推荐使用 uv**：经测试，uv 与 F5-TTS 存在依赖冲突，建议使用传统的 pip + venv 方案。

## 🔧 维护指南

### 日常操作

```bash
# 启动所有服务
./restart_services.sh

# 停止所有服务
./stop_services.sh

# 检查运行状态
./check_status.sh

# 查看日志
./watch_f5tts_log.sh
./watch_indextts_log.sh
./watch_tunnel_log.sh
```

### 更新模型

```bash
# 更新 F5-TTS
cd F5-TTS
git pull
source .venv/bin/activate
pip install -e .
pip install "gradio==5.44.0"  # 重新锁定版本

# 更新 IndexTTS
cd ../index-tts
git pull
# 根据项目更新说明安装依赖
```

### 查看端口占用

```bash
# 检查端口
lsof -i :7860  # F5-TTS
lsof -i :7861  # IndexTTS

# 杀死进程
kill -9 <PID>
```

### 清理日志

```bash
# 清理旧日志
rm -f F5-TTS/f5tts.log index-tts/indextts.log tunnel.log
```

## 📊 性能优化

### Cloudflare Tunnel 优化

在 `config.yml` 中调整超时时间，适应 TTS 长时间处理：

```yaml
originRequest:
  connectTimeout: 300s      # 连接超时 5 分钟
  keepAliveTimeout: 300s    # 保活超时 5 分钟
  tcpKeepAlive: 300s        # TCP 保活 5 分钟
  disableChunkedEncoding: true  # 禁用分块传输
```

### F5-TTS 优化

- 使用 GPU 加速（如果可用）
- 限制参考音频长度（<12 秒效果最佳）
- 预先转换音频为 WAV 格式

## 🆚 为什么选择 F5-TTS？

本项目选择 F5-TTS 作为核心引擎，原因如下：

| 特性 | F5-TTS | Bark | CosyVoice | IndexTTS |
|------|--------|------|-----------|----------|
| **许可证** | ✅ MIT | ✅ MIT | ✅ Apache 2.0 | ⚠️ 限制 |
| **商用** | ✅ 无限制 | ✅ 无限制 | ✅ 无限制 | ⚠️ 有限制 |
| **中文** | ✅ 良好 | ⚠️ 一般 | ✅✅ 优秀 | ✅✅ 优秀 |
| **英文** | ✅✅ 优秀 | ✅✅ 优秀 | ✅ 良好 | ⚠️ 一般 |
| **速度** | ✅✅ 快 | ❌ 慢 | ⚠️ 中等 | ✅ 较快 |
| **零样本** | ✅ 支持 | ✅ 支持 | ✅ 支持 | ✅ 支持 |
| **模型大小** | ~2GB | ~5-8GB | ~10-15GB | ~2GB |
| **维护** | ✅ 活跃 | ⚠️ 较少 | ✅ 活跃 | ✅ 活跃 |

**选择理由**:
1. ✅ **MIT 许可证** - 商用完全无限制，法律风险最低
2. ✅ **性能优秀** - 生成速度快，适合生产环境
3. ✅ **中英文均衡** - 两种语言效果都不错
4. ✅ **资源占用小** - 适合本地部署
5. ✅ **社区活跃** - 持续更新和维护

**其他模型评估**: 详见 `BARK_COSYVOICE_EVALUATION.md`

## 🎓 学习资源

- [F5-TTS 官方文档](https://github.com/SWivid/F5-TTS)
- [IndexTTS 官方文档](https://github.com/indexxlabs/index-tts)
- [Cloudflare Tunnel 文档](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)
- [Gradio 文档](https://www.gradio.app/docs)
- [Bark GitHub](https://github.com/suno-ai/bark)
- [CosyVoice GitHub](https://github.com/FunAudioLLM/CosyVoice)

## 🐛 故障排查

### F5-TTS 无法启动

```bash
# 检查日志
cat F5-TTS/f5tts.log

# 常见问题：
# 1. Python 版本不对：确保使用 Python 3.11
# 2. Gradio 版本错误：确认是 5.44.0
# 3. 端口被占用：lsof -i :7860
```

### Cloudflare Tunnel 连接失败

```bash
# 检查日志
cat tunnel.log

# 验证配置
cloudflared tunnel info tts-tunnel

# 测试连接
cloudflared tunnel run --config ~/.cloudflared/config.yml tts-tunnel
```

### 文件上传失败

1. 检查 Gradio 版本：`pip show gradio`（应为 5.44.0）
2. 清除浏览器缓存
3. 检查文件大小（限制 100MB）
4. 尝试转换为 WAV 格式

## 📝 项目结构

```
tts/
├── README.md                          # 本文档
├── F5TTS_INSTALLATION_COMPLETE.md    # 安装记录
├── UPLOAD_ID_UNDEFINED_FIX.md        # Bug 修复文档
├── start_f5tts.sh                    # F5-TTS 启动脚本
├── start_indextts.sh                 # IndexTTS 启动脚本
├── start_tunnel.sh                   # Tunnel 启动脚本
├── stop_services.sh                  # 停止所有服务
├── restart_services.sh               # 重启所有服务
├── check_status.sh                   # 状态检查
├── watch_f5tts_log.sh               # F5-TTS 日志监控
├── watch_indextts_log.sh            # IndexTTS 日志监控
├── watch_tunnel_log.sh              # Tunnel 日志监控
├── F5-TTS/                          # F5-TTS 源码
│   ├── .venv/                       # Python 3.11 虚拟环境
│   ├── f5tts.log                    # 运行日志
│   └── ...
└── index-tts/                       # IndexTTS 源码
    ├── .venv/                       # Python 虚拟环境
    ├── indextts.log                 # 运行日志
    └── ...
```

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request！

常见改进方向：
- 添加更多 TTS 模型支持
- 优化启动速度
- 添加 Docker 部署方案
- 支持其他操作系统（Linux、Windows）
- 添加 Web 管理界面

## 📄 许可证

本项目脚本和文档采用 MIT 许可证。

F5-TTS 和 IndexTTS 遵循各自的开源许可证。

## ⚠️ 免责声明

1. 本项目仅供学习和研究使用
2. 请遵守 Cloudflare 的服务条款
3. 语音合成内容的使用需遵守相关法律法规
4. 使用前请确保有权使用参考音频

## 📮 联系方式

如有问题，请：
1. 查阅本 README 和相关文档
2. 在 GitHub Issues 提问
3. 参考 F5-TTS 和 IndexTTS 官方文档

---

**最后更新**: 2025年11月23日  
**版本**: 1.0.0  
**状态**: ✅ 生产可用
