#!/bin/bash

# tags_dev路径
dev_next_path="/opt/docker_builder/dev-next/Dockerfile"

# tags_main路径
main_path="/opt/docker_builder/main/Dockerfile"

# 存储Pre-release版本号的文件路径
dev_next_version_file="/opt/docker_builder/dev_next_version.txt"

# 存储Latest版本号的文件路径
main_version_file="/opt/docker_builder/main_version.txt"

# GitHub仓库地址（包括Pre-release）
repo_dev_next_url="https://api.github.com/repos/SagerNet/sing-box/releases"

# GitHub仓库地址（不包括Pre-release）
repo_main_url="https://api.github.com/repos/SagerNet/sing-box/releases/latest"

# 获取最新的Pre-release版本号
dev_next_tag_data=$(curl -s $repo_dev_next_url)
dev_next_tag=$(echo $dev_next_tag_data | jq -r 'map(select(.prerelease == true) | .tag_name) | .[0]')

# 获取最新的Latest版本号
main_tag_data=$(curl -s $repo_main_url)
main_tag=$(echo $main_tag_data | jq -r '.tag_name')

# 检查是否成功获取到最新的Pre-release版本号
if [ -z "$dev_next_tag" ]; then
    echo "无法获取最新的Pre-release版本号。请检查仓库地址和网络连接。"
    exit 1
fi

# 检查是否成功获取到最新的Latest版本号
if [ -z "$main_tag" ]; then
    echo "无法获取最新的Latest版本号。请检查仓库地址和网络连接。"
    exit 1
fi

# 读取存储的Pre-release版本号
if [ -e "$dev_next_version_file" ]; then
    stored_dev_next_version=$(cat "$dev_next_version_file")
else
    stored_dev_next_version=""
fi

# 读取存储的Latest版本号
if [ -e "$main_version_file" ]; then
    stored_main_version=$(cat "$main_version_file")
else
    stored_main_version=""
fi

# 检查Latest版本号是否有变动
if [ "$main_tag" != "$stored_main_version" ]; then
    # 如果Latest版本号有变动，则更新版本号到文件中
    echo "$main_tag" > "$main_version_file"
    
    # 更新Dockerfile中的版本号
    sed -i "s/git clone -b [^[:space:]]* --single-branch/git clone -b $main_tag --single-branch/g" "$main_path"

    # 执行 Docker 命令
    docker buildx build --platform linux/i386,linux/amd64,linux/arm/v7,linux/arm64 --push -t 用户名/仓库名:$main_tag -f /opt/docker_builder/main/Dockerfile .
    docker buildx build --platform linux/i386,linux/amd64,linux/arm/v7,linux/arm64 --push -t 用户名/仓库名:latest -f /opt/docker_builder/main/Dockerfile .
else
    # 如果Latest版本号没有变动，则输出提示信息
    echo "Latest版本号没有变动，无需执行更新 Latest Docker 命令。"
fi

# 检查Pre-release版本号是否有变动
if [ "$dev_next_tag" != "$stored_dev_next_version" ]; then
    # 如果Pre-release版本号有变动，则更新版本号到文件中
    echo "$dev_next_tag" > "$dev_next_version_file"
    
    # 更新Dockerfile中的版本号
    sed -i "s/git clone -b [^[:space:]]* --single-branch/git clone -b $dev_next_tag --single-branch/g" "$dev_next_path"

    # 执行 Pre-release Docker 命令
    docker buildx build --platform linux/i386,linux/amd64,linux/arm/v7,linux/arm64 --push -t 用户名/仓库名:$dev_next_tag -f /opt/docker_builder/dev-next/Dockerfile .
    docker buildx build --platform linux/i386,linux/amd64,linux/arm/v7,linux/arm64 --push -t 用户名/仓库名:dev-next -f /opt/docker_builder/dev-next/Dockerfile .
else
    # 如果Pre-release版本号没有变动，则输出提示信息
    echo "Pre-release版本号没有变动，无需执行更新 Pre-release 命令。"
fi
