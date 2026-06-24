#!/bin/bash
# 创建人:   yaobo
# 创建时间: 2021.02.28
 
echo "======================安装 docker=============================="

mkdir -p /data/docker && mkdir -p /etc/docker/

# 安装docker
apt update && apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common && apt install docker.io

#设置docker 配置
if [ -e /etc/docker/daemon.json ]; then
    mv  /etc/docker/daemon.json /etc/docker/daemon.json.bak
fi

# 创建systemd
cat >> /etc/docker/daemon.json << EOF
{
  "data-root": "/data/docker",
  "registry-mirrors": ["https://registry.docker-cn.com","http://hub-mirror.c.163.com"], 
  "dns":[$DockerDns],
  "insecure-registries": [$DockerInsecure]
}

EOF


systemctl daemon-reload
systemctl emable docker
systemctl restart docker
docker info


echo "======================安装 docker-compose=============================="
cp ./docker/docker-compose-linux-x86_64  /usr/local/bin/docker-compose

# 添加执行权限
chmod +x /usr/local/bin/docker-compose

# 创建软链接
ln -s /usr/local/bin/docker-compose /usr/bin/

# 输出docker-compose版本
echo "docker-compose --version"
docker-compose --version
docker ps -a