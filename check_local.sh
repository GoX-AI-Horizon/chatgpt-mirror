#!/bin/bash

# 获取当前外部 IP 地址
current_ip=$(curl -s https://api.ipify.org)
echo "Current IP: $current_ip"

# 检测 ChatGPT 可用性
chatgpt_status=$(curl -s -o /dev/null -w "%{http_code}" -L https://chatgpt.com)
if [ "$chatgpt_status" -eq 200 ]; then
    echo "ChatGPT is accessible."
else
    echo "ChatGPT is not accessible. Final status code: $chatgpt_status"
fi

# 检测 Netflix 可用性
netflix_status=$(curl -s -o /dev/null -w "%{http_code}" -L https://www.netflix.com)
if [ "$netflix_status" -eq 200 ]; then
    echo "Netflix is accessible."
else
    echo "Netflix is not accessible. Final status code: $netflix_status"
fi