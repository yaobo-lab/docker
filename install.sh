#!/bin/bash
# 创建人:   yaobo
# 创建时间: 2021.02.28

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_SOURCE="${SCRIPT_DIR}/docker-compose-linux-x86_64"
DOCKER_DATA_ROOT="${DOCKER_DATA_ROOT:-/data/docker}"
DOCKER_DNS="${DOCKER_DNS:-${DockerDns:-}}"
DOCKER_INSECURE_REGISTRIES="${DOCKER_INSECURE_REGISTRIES:-${DockerInsecure:-}}"
DAEMON_JSON="/etc/docker/daemon.json"
NGINX_SIGNING_KEY_URL="https://nginx.org/keys/nginx_signing.key"
NGINX_SIGNING_KEY_FILE="/etc/apt/trusted.gpg.d/nginx.asc"

ensure_nginx_apt_key() {
    if ! grep -Rqs "nginx.org/packages" /etc/apt/sources.list /etc/apt/sources.list.d 2>/dev/null; then
        return
    fi

    echo "Detected nginx apt repository, refreshing nginx signing key..."
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$NGINX_SIGNING_KEY_URL" -o "$NGINX_SIGNING_KEY_FILE"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO "$NGINX_SIGNING_KEY_FILE" "$NGINX_SIGNING_KEY_URL"
    else
        echo "curl or wget is required to refresh nginx signing key before apt update"
        exit 1
    fi

    chmod 0644 "$NGINX_SIGNING_KEY_FILE"
}

if [ "$(id -u)" -ne 0 ]; then
    echo "请使用 root 用户执行该脚本"
    exit 1
fi

echo "======================安装 docker=============================="

mkdir -p "$DOCKER_DATA_ROOT" /etc/docker/

# 安装docker
ensure_nginx_apt_key
apt update
apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common docker.io

#设置docker 配置
if [ -e "$DAEMON_JSON" ]; then
    cp "$DAEMON_JSON" "${DAEMON_JSON}.bak.$(date +%Y%m%d%H%M%S)"
fi

# 创建配置
cat > "$DAEMON_JSON" << EOF
{
  "data-root": "$DOCKER_DATA_ROOT",
  "registry-mirrors": ["https://registry.docker-cn.com", "http://hub-mirror.c.163.com"]
EOF

if [ -n "$DOCKER_DNS" ]; then
    sed -i '$ s/$/,/' "$DAEMON_JSON"
    cat >> "$DAEMON_JSON" << EOF
  "dns": [$DOCKER_DNS]
EOF
fi

if [ -n "$DOCKER_INSECURE_REGISTRIES" ]; then
    sed -i '$ s/$/,/' "$DAEMON_JSON"
    cat >> "$DAEMON_JSON" << EOF
  "insecure-registries": [$DOCKER_INSECURE_REGISTRIES]
EOF
fi

cat >> "$DAEMON_JSON" << EOF
}
EOF

systemctl daemon-reload
systemctl enable docker
systemctl restart docker
docker info


echo "======================安装 docker-compose=============================="
if [ ! -f "$COMPOSE_SOURCE" ]; then
    echo "未找到 docker-compose 安装文件: $COMPOSE_SOURCE"
    exit 1
fi

install -m 0755 "$COMPOSE_SOURCE" /usr/local/bin/docker-compose

# 创建软链接
ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

# 输出docker-compose版本
docker-compose --version
docker ps -a
