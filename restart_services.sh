#!/bin/bash
echo "🔄 重启所有服务..."

# 停止服务
./stop_services.sh

# 等待一会确保端口释放
sleep 2

# 启动服务
./start_tunnel.sh
./start_f5tts.sh
./start_indextts.sh

echo "✅ 所有服务已重启"
./check_status.sh
