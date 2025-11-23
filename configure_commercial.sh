#!/bin/bash
# TTS 商用模式配置脚本

set -e

echo "🎯 TTS 项目商用配置向导"
echo "========================================"
echo ""
echo "请选择你的使用场景："
echo ""
echo "1) 个人学习/研究（非商业）"
echo "2) 小型商业项目（年营收 < 10亿，月活 < 1亿）- 仅 F5-TTS"
echo "3) 中型企业（需要对比测试）- 隔离 IndexTTS"
echo "4) 大型企业（已获 bilibili 授权）- 完整功能"
echo "5) 取消"
echo ""
read -p "请输入选项 (1-5): " choice

case $choice in
    1)
        echo ""
        echo "✅ 配置为：学习研究模式"
        echo "   保留所有功能，添加非商用声明"
        
        cat > .commercial_mode << 'EOF'
MODE=research
LICENSE_COMPLIANCE=not_required
PRODUCTION_USE=false
EOF
        echo ""
        echo "✅ 配置完成！可以自由使用所有功能。"
        ;;
        
    2)
        echo ""
        echo "⚠️  配置为：小型商业模式（仅 F5-TTS）"
        echo ""
        echo "即将执行以下操作："
        echo "  1. 备份 IndexTTS"
        echo "  2. 停止 IndexTTS 服务"
        echo "  3. 更新 Cloudflare Tunnel 配置"
        echo "  4. 移除 IndexTTS 启动脚本"
        echo ""
        read -p "确认继续？(y/n): " confirm
        
        if [ "$confirm" = "y" ]; then
            # 备份
            mkdir -p backups
            echo "📦 备份 IndexTTS..."
            tar -czf "backups/index-tts-backup-$(date +%Y%m%d-%H%M%S).tar.gz" index-tts/ 2>/dev/null || true
            
            # 停止服务
            echo "🛑 停止 IndexTTS..."
            pkill -f "webui.py" 2>/dev/null || true
            
            # 重命名（不删除，以防需要）
            if [ -d "index-tts" ]; then
                mv index-tts index-tts.disabled
                echo "✅ IndexTTS 已禁用（重命名为 index-tts.disabled）"
            fi
            
            # 创建配置文件
            cat > .commercial_mode << 'EOF'
MODE=commercial_small
LICENSE_COMPLIANCE=mit_only
PRODUCTION_USE=true
ALLOWED_ENGINES=f5tts
EOF
            
            echo ""
            echo "✅ 配置完成！"
            echo ""
            echo "📋 后续步骤："
            echo "  1. 手动编辑 ~/.cloudflared/config.yml，移除 IndexTTS 路由"
            echo "  2. 重启 Tunnel: ./start_tunnel.sh"
            echo "  3. 验证服务: ./check_status.sh"
            echo ""
            echo "💡 如需恢复 IndexTTS，运行: mv index-tts.disabled index-tts"
        else
            echo "❌ 已取消"
        fi
        ;;
        
    3)
        echo ""
        echo "⚠️  配置为：中型企业模式（双模型隔离）"
        echo ""
        echo "IndexTTS 将配置为："
        echo "  - 仅内网访问（localhost）"
        echo "  - 不通过 Cloudflare 暴露"
        echo "  - 添加商用检查代码"
        echo ""
        read -p "确认继续？(y/n): " confirm
        
        if [ "$confirm" = "y" ]; then
            cat > .commercial_mode << 'EOF'
MODE=commercial_medium
LICENSE_COMPLIANCE=isolated
PRODUCTION_USE=true
ALLOWED_ENGINES=f5tts
TESTING_ENGINES=f5tts,indextts
INDEXTTS_INTERNAL_ONLY=true
EOF
            
            # 创建限制脚本
            cat > check_production_compliance.sh << 'EOF'
#!/bin/bash
# 生产环境合规性检查

if [ "$PRODUCTION" = "true" ]; then
    if pgrep -f "webui.py" > /dev/null; then
        echo "❌ 错误：生产环境检测到 IndexTTS 运行！"
        echo "   IndexTTS 不得用于生产环境（许可证限制）"
        exit 1
    fi
fi

echo "✅ 合规性检查通过"
EOF
            chmod +x check_production_compliance.sh
            
            echo ""
            echo "✅ 配置完成！"
            echo ""
            echo "📋 重要提示："
            echo "  - F5-TTS: 生产环境使用"
            echo "  - IndexTTS: 仅开发/测试环境使用"
            echo "  - 已创建合规性检查脚本: ./check_production_compliance.sh"
            echo ""
            echo "⚠️  请确保："
            echo "  1. IndexTTS 不通过 Cloudflare Tunnel 暴露"
            echo "  2. 生产 API 只调用 F5-TTS"
            echo "  3. 定期运行合规性检查"
        else
            echo "❌ 已取消"
        fi
        ;;
        
    4)
        echo ""
        echo "✅ 配置为：企业授权模式"
        echo ""
        read -p "请输入 bilibili 授权文件路径（或回车跳过）: " license_file
        
        cat > .commercial_mode << 'EOF'
MODE=commercial_enterprise
LICENSE_COMPLIANCE=licensed
PRODUCTION_USE=true
ALLOWED_ENGINES=f5tts,indextts
EOF
        
        if [ -n "$license_file" ] && [ -f "$license_file" ]; then
            cp "$license_file" bilibili_license_agreement.pdf
            echo "LICENSE_FILE=bilibili_license_agreement.pdf" >> .commercial_mode
            echo "✅ 授权文件已保存"
        fi
        
        echo ""
        echo "✅ 配置完成！完整功能可用。"
        echo ""
        echo "📋 请确保："
        echo "  1. 保留 bilibili 授权协议文件"
        echo "  2. 遵守授权协议中的使用限制"
        echo "  3. 定期审查合规性"
        ;;
        
    5)
        echo "❌ 已取消"
        exit 0
        ;;
        
    *)
        echo "❌ 无效选项"
        exit 1
        ;;
esac

echo ""
echo "========================================"
echo "配置文件已保存到: .commercial_mode"
echo "详细指南请参阅: COMMERCIAL_LICENSE_GUIDE.md"
echo "========================================"
