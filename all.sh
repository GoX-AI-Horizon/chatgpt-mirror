#!/bin/bash

# 更新系统包列表
sudo apt update

# 安装 Docker
curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh

# 克隆 Git 仓库
sudo git clone https://github.com/GoX-AI-Horizon/chatgpt-mirror.git /home/chatgpt-mirror

# 进入克隆的目录
cd /home/chatgpt-mirror

# 复制环境变量示例文件并编辑
sudo cp .env.example .env
sudo vi .env  # 手动编辑 .env 文件

# 部署项目
sudo ./deploy.sh

# 安装 Certbot
sudo apt install certbot -y

# 使用 Certbot 获取 SSL 证书
sudo certbot certonly --standalone -d ai.taskchatshare.top

# 安装 Nginx
sudo apt install nginx -y

# 启动并启用 Nginx 服务
sudo systemctl start nginx
sudo systemctl enable nginx

# 配置 Nginx 站点
sudo nano /etc/nginx/sites-available/ai.taskchatshare.top  # 手动编辑配置文件

# 创建符号链接以启用站点
sudo ln -s /etc/nginx/sites-available/ai.taskchatshare.top /etc/nginx/sites-enabled/

# 测试 Nginx 配置
sudo nginx -t

# 创建日志目录
sudo mkdir -p /data/logs

# 重新加载 Nginx 配置
sudo systemctl reload nginx