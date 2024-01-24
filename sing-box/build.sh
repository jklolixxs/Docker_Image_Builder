#!/bin/bash
# 主目录
local_path="/opt/Docker_Image_Builder/sing-box"
# Dockerfile路径
dockerfile_path="/opt/Docker_Image_Builder/sing-box/Dockerfile"
# 存储版本号的文件路径
version_file="/opt/Docker_Image_Builder/sing-box/version_file.txt"
# Docker Hub的用户名
username="用户名"
# Docker Hub中的仓库名
repositories="仓库名"

# 读取本地储存的main_next版本号与dev_next版本号
main_next_local_tag=$(awk '/main-next/{print $NF; exit}' $version_file)
dev_next_local_tag=$(awk '/dev-next/{print $NF; exit}' $version_file)
# 获取最新的main_next版本号与dev_next版本号（使用awk与jq两种方式，任选自己喜欢的方式，默认使用awk）
read_tags=$(wget -qO- --tries=3 "https://api.github.com/repos/SagerNet/sing-box/releases" | awk -F '"' '/tag_name/{print $(NF-1)}')
# read_tags=$(wget -qO- --tries=3 "https://api.github.com/repos/SagerNet/sing-box/releases" | jq -r '.[].tag_name')
main_next_tag=$(grep -vm1 '-' <<<"$read_tags")
dev_next_tag=$(grep -m1 '-' <<<"$read_tags")

# 检查是否成功获取到最新的版本号
if [ -z "$main_next_tag" ] || [ -z "$dev_next_tag" ]; then
    echo "无法获取最新的main-next版本号"
    echo "1.请检查与GitHub之间的网络连接是否通畅"
    echo "2.如短时间内读取版本号过多，可能会出发GitHub限制，请最短每分钟一次"
    exit 1
fi

# 检查main_next版本号是否有变动
if [ "$main_next_local_tag" != "$main_next_tag" ]; then
    # 更新main_next版本号
    sed -i "s/\(main-next.*:\).*/\1 $main_next_tag/" $version_file

    # 更新临时Dockerfile中的版本号
    mkdir -p $local_path/tmp/main-next/ && cp $dockerfile_path $local_path/tmp/main-next/Dockerfile
    sed -i "s/git clone -b [^[:space:]]* --single-branch/git clone -b $main_next_tag --single-branch/g" "$local_path/tmp/main-next/Dockerfile"

    # 执行 Docker 命令
    docker buildx build --platform linux/i386,linux/amd64,linux/arm/v7,linux/arm64 --push -t $username/$repositories:$main_next_tag -f "$local_path/tmp/main-next/Dockerfile" .
    docker buildx build --platform linux/i386,linux/amd64,linux/arm/v7,linux/arm64 --push -t $username/$repositories:latest -f "$local_path/tmp/main-next/Dockerfile" .
    echo "成功编译，当前main-next版本号为$main_next_tag"

    # 移除临时Dockerfile
    rm -rf $version_file/tmp/
else
    # 如果main_next版本号没有变动，则输出提示信息
    echo "main_next版本号没有变动，无需执行更新 main_next Docker 命令。"
fi

# 检查dev_next版本号是否有变动
if [ "$dev_next_local_tag" != "$dev_next_tag" ]; then
    # 更新dev_next版本号
    sed -i "s/\(dev-next.*:\).*/\1 $dev_next_tag/" $version_file

    # 更新临时Dockerfile中的版本号
    mkdir -p $local_path/tmp/dev-next/ && cp $dockerfile_path $local_path/tmp/dev-next/Dockerfile
    sed -i "s/git clone -b [^[:space:]]* --single-branch/git clone -b $dev_next_tag --single-branch/g" "$local_path/tmp/dev-next/Dockerfile"

    # 执行 Docker 命令
    docker buildx build --platform linux/i386,linux/amd64,linux/arm/v7,linux/arm64 --push -t $username/$repositories:$dev_next_tag -f "$local_path/tmp/dev-next/Dockerfile" .
    docker buildx build --platform linux/i386,linux/amd64,linux/arm/v7,linux/arm64 --push -t $username/$repositories:dev-next -f "$local_path/tmp/dev-next/Dockerfile" .
    echo "成功编译，当前dev-next版本号为$dev_next_tag"

    # 移除临时Dockerfile
    rm -rf $version_file/tmp/dev-next/Dockerfile
else
    # 如果dev_next版本号没有变动，则输出提示信息
    echo "dev_next版本号没有变动，无需执行更新 dev_next Docker 命令。"
fi
