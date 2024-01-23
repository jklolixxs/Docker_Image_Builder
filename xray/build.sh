#!/bin/bash
# 检测 jq 是否安装
if ! command -v jq &> /dev/null; then
    echo "jq 并未安装，请自行安装"
    echo "Debian/Ubuntu: apt install -y jq"
    echo "Centos: yum install -y jq"
    exit 1
fi

# 主目录
local_path="/opt/docker_builder/xray"
# Dockerfile路径
dockerfile_path="/opt/docker_builder/xray/Dockerfile"
# 存储版本号的文件路径
version_file="/opt/docker_builder/xray/version_file.txt"
# 用户名
username="jklolixxs"
# 仓库名
repositories="xray"

# 读取本地储存的版本号
local_tag=$(awk '/latest/{print $NF; exit}' $version_file)
# 获取最新版本的版本号
new_tags=$(curl -s 'https://api.github.com/repos/XTLS/Xray-core/releases' | jq -r '.[0].tag_name')

# 检查是否成功获取到最新的版本号
if [ -z "$new_tags" ] ; then
    echo "无法获取最新的版本号"
    echo "1.请检查与GitHub之间的网络连接是否通畅"
    echo "2.如短时间内读取版本号过多，可能会出发GitHub限制，请最短每分钟一次"
    exit 1
fi

# 检查main_next版本号是否有变动
if [ "$local_tag" != "$new_tags" ]; then
    # 更新main_next版本号
    sed -i "s/\(latest.*:\).*/\1 $new_tags/" $version_file

    # 更新临时Dockerfile中的版本号
    mkdir -p $local_path/tmp/latest/ && cp $dockerfile_path $local_path/tmp/latest/Dockerfile
    sed -i "s/git clone -b [^[:space:]]* --single-branch/git clone -b $new_tags --single-branch/g" "$local_path/tmp/latest/Dockerfile"

    # 执行 Docker 命令
    docker buildx build --platform linux/i386,linux/amd64,linux/arm/v7,linux/arm64 --push -t $username/$repositories:$new_tags -f "$local_path/tmp/latest/Dockerfile" .
    docker buildx build --platform linux/i386,linux/amd64,linux/arm/v7,linux/arm64 --push -t $username/$repositories:latest -f "$local_path/tmp/latest/Dockerfile" .
    echo "成功编译，当前latest版本号为$new_tags"

    # 移除临时Dockerfile
    rm -rf $local_path/tmp
else
    # 如果版本号没有变动，则输出提示信息
    echo "最新版与当前版本相同，版本号没有变动，无需执行更新更新 Docker 镜像指令。"
fi
