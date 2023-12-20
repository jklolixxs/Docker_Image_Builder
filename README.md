# Sing-Box 镜像构建
- **本着授人以鱼不如授人以渔的原则，现公开 **https://hub.docker.com/r/jklolixxs/sing-box** 镜像的构建方法**

## ❗❗❗如下操作均为Linux系统中的命令行操作❗❗❗

## 1.安装Docker 与 必备程序
#### 使用Dcker官方一键安装脚本  
>`curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh`  
#### 安装jq软件以供筛选版本号  
>Debian/Ubuntu 使用 `apt install -y jq`  
centos 使用 `yum install -y jq`  
其他系统请按照各自的软件包管理程序安装软件 **jq**

## 2.执行编译前的必要命令
> `docker buildx create --use`  
> `docker buildx inspect --bootstrap`  
> 这两个命令通常用于设置和准备Docker Buildx，以便能够使用其功能构建适用于多个CPU架构和操作系统的容器镜像
直接使用

> `docker login`  
> 在您的机器上登录Docker Hub账号，用以后面向账号中的仓库推送镜像

## 3.下载仓库文件
如果您不知道在哪里下载仓库压缩包，可以 **[点击此处一键下载](https://codeload.github.com/jklolixxs/docker_builder/zip/refs/heads/main)**

## 4.解压
将下载后的压缩包内的内容，集体解压到 **/opt/docker_builder/** 文件夹中

## 5.更改细节
用您喜欢的文本编辑器，编辑 **run.sh** 文件中的的内容  
找到63 64和80 81行，将 `用户名`修改为您的Docker Hub用户名，将 `仓库名` 修改为您像推送到的Docker Hub仓库的名字，如果没有这个命名的仓库也没关系，会自动创建然后推送

## 6.提权
给予一键编译脚本权限  
`chmod +x /opt/docker_builder/run.sh`

## 7.开始编译
运行命令，脚本会自动开始查询最新版本号，并开始，编译成功后会自动推送至对应仓库  
`/opt/docker_builder/run.sh`
