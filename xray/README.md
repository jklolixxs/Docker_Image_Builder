# ❗❗❗如下操作均为Linux系统中的命令行操作❗❗❗

## 1.安装Docker 与 必备程序
#### 使用Dcker官方一键安装脚本  
```
curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh
```
#### （如果您之前有安装Docker，则无需再次执行，略过此条向下继续查看）

## 2.执行编译前的必要命令
```
docker buildx create --use  
docker buildx inspect --bootstrap  
docker login
```
#### 这两个命令通常用于设置和准备Docker Buildx，以便能够使用其功能构建适用于多个CPU架构和操作系统的容器镜像  
#### （如果您之前有执行这两条命令，则无需再次执行，略过此条向下继续查看）

## 3.拉取仓库
* 方法一：使用git拉取  
```
git clone https://github.com/jklolixxs/Docker_Image_Builder.git /opt/Docker_Image_Builder
```
* 方法二：下载压缩包自行解压
  > 如果您不知道在哪里下载仓库压缩包，可以 **[点击此处一键下载](https://codeload.github.com/jklolixxs/Docker_Image_Builder/zip/refs/heads/main)**

## 4.检查路径
检查 **xray** 文件夹是否存在于 /opt/Docker_Image_Builder/ 路径中  

## 5.更改细节
用您喜欢的文本编辑器，编辑 `/opt/Docker_Image_Builder/xray/build.sh` 文件中的的内容  
找到9 11行，将 `用户名`修改为您的Docker Hub用户名，将 `仓库名` 修改为您像推送到的Docker Hub仓库的名字，如果没有这个命名的仓库也没关系，会自动创建然后推送

## 6.提权
给予一键编译脚本权限  
```
chmod +x /opt/Docker_Image_Builder/xray/build.sh
```

## 7.开始编译
运行命令，脚本会自动开始查询最新版本号，并开始，编译成功后会自动推送至对应仓库  
```
/opt/Docker_Image_Builder/xray/build.sh
```

## 8.关于全自动构建推送
使用Linux自带的 **crontab** 来定时执行编译脚本  
使用指令 `crontab -e -u root` 进入，在最后一行添加
```
* */1 * * * /opt/Docker_Image_Builder/xray/build.sh
```
保存并退出后，全自动构建脚本会每小时检查一次版本号，如果有变动，则会自动在后台进入构建并推送（不宜设置过短，容易触发GitHub限制，导致版本号查询失败）
>`crontab`: 用于编辑、查看或删除用户的 crontab 文件。  
>`-e`: 表示编辑 crontab 文件。  
>`-u root`: 指定要编辑的用户。在这里，root 是目标用户。  
