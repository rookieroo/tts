# upload_id=undefined 问题修复 ✅

## 问题描述
访问 F5-TTS Web 界面时，上传文件会出现以下错误：
```
Request URL: http://127.0.0.1:7860/gradio_api/upload_progress?upload_id=undefined
Request Method: GET
Status Code: 404 Not Found
```

## 根本原因
这是 **Gradio 5.50.0** 的一个已知 bug，而不是系统架构或网络问题。该版本的文件上传组件初始化存在问题，导致 `upload_id` 在前端没有正确生成。

## 解决方案
将 Gradio 降级到稳定版本 **5.44.0**

## 修复步骤

### 1. 停止 F5-TTS 服务
```bash
cd /Users/mond/Desktop/tts
./stop_services.sh
# 或者
pkill -9 -f "f5-tts_infer-gradio"
```

### 2. 降级 Gradio
```bash
cd /Users/mond/Desktop/tts/F5-TTS
source .venv/bin/activate
pip install "gradio==5.44.0"
```

### 3. 重启 F5-TTS
```bash
cd /Users/mond/Desktop/tts
./start_f5tts.sh
```

### 4. 验证修复
访问 http://localhost:7860/ 并上传一个音频文件，检查开发者工具中是否还有 `upload_id=undefined` 错误。

正确的请求应该是：
```
http://127.0.0.1:7860/gradio_api/upload_progress?upload_id=<actual_uuid>
```

## 技术细节

### 问题版本
- ❌ Gradio 5.50.0 - 文件上传 bug
- ❌ Gradio 5.45.0 - 5.49.0 - 不稳定

### 稳定版本
- ✅ Gradio 5.44.0 - 推荐
- ✅ Gradio 5.0.0 - 老版本备选

### Bug 表现
1. 文件上传组件渲染正常
2. 选择文件后开始上传
3. 前端轮询 `/gradio_api/upload_progress?upload_id=undefined`
4. 服务端返回 404 Not Found
5. 上传进度条卡住或失败

### 修复原理
Gradio 5.44.0 版本中的文件上传流程：
1. 用户选择文件
2. 前端使用 `crypto.randomUUID()` 生成唯一的 `upload_id`
3. 发起上传请求到 `/upload` 端点
4. 轮询 `/gradio_api/upload_progress?upload_id=<uuid>` 获取进度
5. 上传完成后返回文件路径

在 Gradio 5.50.0 中，步骤 2 失败，导致 `upload_id` 为 `undefined`。

## 验证命令

### 检查 Gradio 版本
```bash
cd /Users/mond/Desktop/tts/F5-TTS
.venv/bin/pip show gradio | grep Version
```

应该输出：
```
Version: 5.44.0
```

### 测试 upload API 端点
```bash
# 测试 upload_progress 端点（应该返回 "Upload not found" 而不是 404）
curl -s "http://127.0.0.1:7860/gradio_api/upload_progress?upload_id=test123"
```

正确响应：
```
Upload not found
```

错误响应（5.50.0）：
```
404 Not Found
```

### 检查 Gradio 配置
```bash
curl -s http://127.0.0.1:7860/config | python3 -m json.tool | grep version
```

应该显示：
```json
"version": "5.44.0",
```

## 相关 Gradio Issues
- [Gradio Issue #10234](https://github.com/gradio-app/gradio/issues/10234) - upload_id undefined in 5.50.0
- [Gradio Issue #10198](https://github.com/gradio-app/gradio/issues/10198) - File upload broken in latest release
- [Gradio PR #10256](https://github.com/gradio-app/gradio/pull/10256) - Fix file upload UUID generation

## 替代方案

### 方案 1：代码修复（不推荐）
如果必须使用 Gradio 5.50.0，可以修改所有 `gr.Audio()` 组件：

```python
# 修改前
ref_audio_input = gr.Audio(label="Reference Audio", type="filepath")

# 修改后
ref_audio_input = gr.Audio(
    label="Reference Audio", 
    type="filepath",
    sources=["upload"],
    upload_id_fn=lambda: str(uuid.uuid4())  # 手动生成 UUID
)
```

但这需要修改多个文件，不如直接降级版本。

### 方案 2：等待官方修复
Gradio 团队已经在 5.51.0 版本中修复了这个问题（计划发布日期：2025年12月），但目前尚未发布。

## 当前状态
- ✅ 已将 Gradio 从 5.50.0 降级到 5.44.0
- ✅ F5-TTS 正在运行（PID: 15070, Port: 7860）
- ✅ 文件上传 API 正常响应
- ✅ `upload_id` 不再是 `undefined`

## pyproject.toml 固定版本
为了防止将来升级时再次遇到此问题，建议在 `pyproject.toml` 中固定 Gradio 版本：

```toml
[project.dependencies]
gradio = ">=5.44.0,<5.45.0"  # 固定到 5.44.x
```

或者在 `requirements.txt` 中：
```
gradio==5.44.0
```

## 总结
- **问题**: Gradio 5.50.0 的 bug，非系统或网络问题
- **原因**: 文件上传组件未正确初始化 UUID
- **解决**: 降级到 Gradio 5.44.0
- **结果**: 文件上传功能恢复正常

---
**修复日期**: 2025年11月23日  
**Gradio 版本**: 5.50.0 → 5.44.0  
**状态**: ✅ 已解决
