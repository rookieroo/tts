# Git 仓库管理指南

## 📂 项目结构

```
tts/                              # 你的主项目仓库
├── .git/                         # 主仓库 Git
├── .gitmodules                   # Submodules 配置
├── F5-TTS/                       # Git Submodule → SWivid/F5-TTS
│   ├── .git/                     # 子模块 Git
│   ├── .venv/                    # 虚拟环境（不提交）
│   └── src/                      # 源码（可能有本地修改）
├── index-tts/                    # Git Submodule → index-tts/index-tts
│   ├── .git/                     # 子模块 Git
│   ├── .venv/                    # 虚拟环境（不提交）
│   └── ...
├── README.md                     # 你的项目文档
├── *.sh                          # 你的管理脚本
└── *.md                          # 你的配置文档
```

## 🎯 为什么使用 Git Submodules？

### 优点
1. ✅ **保持上游同步**: 轻松拉取 F5-TTS 和 IndexTTS 的最新更新
2. ✅ **独立管理**: 上游仓库和你的项目互不干扰
3. ✅ **版本锁定**: 可以锁定特定版本，稳定可靠
4. ✅ **补丁管理**: 使用 patch 文件管理本地修改

### 缺点
1. ⚠️ 需要额外命令来更新子模块
2. ⚠️ 克隆时需要 `--recursive` 参数

## 🚀 常用命令

### 初次克隆项目（给其他人）

```bash
# 克隆主仓库和所有子模块
git clone --recursive git@github.com:rookieroo/tts.git

# 或者分两步
git clone git@github.com:rookieroo/tts.git
cd tts
git submodule update --init --recursive
```

### 更新上游代码

#### 更新 F5-TTS

```bash
cd F5-TTS

# 方法 1: 拉取最新代码（推荐先测试）
git fetch origin
git log --oneline -10              # 查看最新提交
git checkout origin/main           # 测试最新版本

# 测试通过后，合并
git merge origin/main

# 方法 2: 切换到特定版本
git checkout v1.2.0                # 切换到稳定版本
git checkout <commit-hash>         # 切换到特定提交

# 应用我们的补丁
cd ..
./apply_patches.sh

# 测试
./restart_services.sh
```

#### 更新 index-tts

```bash
cd index-tts
git pull origin main
cd ..
./restart_services.sh
```

#### 更新所有子模块

```bash
# 更新所有子模块到最新版本
git submodule update --remote

# 应用补丁
./apply_patches.sh

# 提交子模块版本更新
git add F5-TTS index-tts
git commit -m "chore: update submodules to latest"
```

### 查看当前版本

```bash
# 查看所有子模块状态
git submodule status

# 查看 F5-TTS 版本
cd F5-TTS && git log -1 --oneline && cd ..

# 查看 index-tts 版本
cd index-tts && git log -1 --oneline && cd ..
```

### 锁定稳定版本

```bash
# 切换到稳定版本
cd F5-TTS
git checkout v1.1.9                # 或特定的 commit hash
cd ..

# 提交版本锁定
git add F5-TTS
git commit -m "chore: lock F5-TTS to v1.1.9"
git push
```

### 管理本地修改

#### 保存修改为补丁

```bash
cd F5-TTS

# 查看修改
git status
git diff

# 创建补丁文件
git diff > ../patches/f5tts-$(date +%Y%m%d).patch

# 或者只针对特定文件
git diff src/f5_tts/infer/infer_gradio.py > ../patches/gradio-fix.patch
```

#### 应用补丁

```bash
cd F5-TTS

# 应用补丁
git apply ../patches/f5tts-20251123.patch

# 或使用我们的脚本
cd ..
./apply_patches.sh
```

#### 重置修改

```bash
cd F5-TTS

# 丢弃所有本地修改
git reset --hard HEAD

# 重新应用补丁
cd ..
./apply_patches.sh
```

## 📝 提交到你的仓库

### 日常提交

```bash
# 添加文件
git add README.md *.sh *.md

# 提交
git commit -m "docs: update README"

# 推送
git push origin main
```

### 包含子模块版本更新

```bash
# 子模块更新后
cd F5-TTS
git checkout <new-version>
cd ..

# 提交子模块版本变更
git add F5-TTS
git commit -m "chore: update F5-TTS to <version>"
git push origin main
```

## 🔄 工作流程示例

### 场景 1: F5-TTS 发布新版本

```bash
# 1. 备份当前工作状态
./stop_services.sh
tar -czf backups/working-state-$(date +%Y%m%d).tar.gz F5-TTS/ index-tts/

# 2. 更新 F5-TTS
cd F5-TTS
git fetch origin
git log --oneline origin/main -5  # 查看更新内容
git checkout origin/main

# 3. 重新应用补丁
cd ..
./apply_patches.sh

# 4. 重新安装依赖
cd F5-TTS
source .venv/bin/activate
pip install -e .
pip install "gradio==5.44.0"
cd ..

# 5. 测试
./start_f5tts.sh
sleep 10
./check_status.sh
curl http://localhost:7860/ | grep "Gradio"

# 6. 如果测试通过，提交
git add F5-TTS
git commit -m "chore: update F5-TTS to latest"
git push

# 7. 如果测试失败，回滚
cd F5-TTS
git checkout <previous-commit>
cd ..
./restart_services.sh
```

### 场景 2: 修改 F5-TTS 源码

```bash
# 1. 修改代码
cd F5-TTS
# 编辑文件...

# 2. 测试修改
cd ..
./restart_services.sh

# 3. 如果测试通过，创建补丁
cd F5-TTS
git diff > ../patches/my-fix-$(date +%Y%m%d).patch

# 4. 更新 apply_patches.sh 包含新补丁

# 5. 更新 PATCHES.md 文档

# 6. 提交补丁文件（不提交 F5-TTS 的修改）
cd ..
git add patches/ apply_patches.sh PATCHES.md
git commit -m "fix: add patch for <issue>"
git push
```

### 场景 3: 新机器部署

```bash
# 1. 克隆仓库
git clone --recursive git@github.com:rookieroo/tts.git
cd tts

# 2. 配置 F5-TTS
cd F5-TTS
/opt/homebrew/bin/python3.11 -m venv .venv
source .venv/bin/activate
pip install torch torchaudio
pip install -e .
pip install "gradio==5.44.0"
cd ..

# 3. 应用补丁
chmod +x *.sh
./apply_patches.sh

# 4. 配置 index-tts
cd index-tts
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cd ..

# 5. 配置 Cloudflare Tunnel
# 按 README.md 说明配置

# 6. 启动服务
./restart_services.sh
```

## ⚠️ 注意事项

### 不要提交的文件（已在 .gitignore）

- `.venv/` - 虚拟环境
- `*.log` - 日志文件
- `*.pth`, `*.pt` - 模型文件
- `__pycache__/` - Python 缓存

### 子模块的 .git 管理

```
F5-TTS/.git 和 index-tts/.git 是链接到主仓库的
不要删除它们，否则子模块会失效
```

### 更新注意

```bash
# ❌ 错误：在子模块中 git pull
cd F5-TTS
git pull origin main          # 这样会脱离主仓库管理

# ✅ 正确：使用 submodule 命令
cd ..
git submodule update --remote F5-TTS
```

## 🆘 常见问题

### 子模块显示 "modified"

```bash
# 查看原因
cd F5-TTS
git status

# 如果是本地修改（补丁）
git diff > ../patches/current-changes.patch
git reset --hard HEAD

# 如果是版本变更
git checkout <desired-version>
cd ..
git add F5-TTS
git commit -m "chore: update F5-TTS version"
```

### 子模块克隆失败

```bash
# 手动初始化
git submodule init
git submodule update

# 或者单独克隆
git submodule update --init --recursive F5-TTS
```

### 子模块版本冲突

```bash
# 查看期望版本
cat .gitmodules

# 重置子模块
git submodule deinit -f F5-TTS
git submodule update --init F5-TTS
```

## 📚 更多资源

- [Git Submodules 官方文档](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
- [F5-TTS GitHub](https://github.com/SWivid/F5-TTS)
- [IndexTTS GitHub](https://github.com/index-tts/index-tts)

---

**最后更新**: 2025年11月23日
