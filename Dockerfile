# —— 终极修复版：Alpine 3.20 + Go 1.25 二进制 + 静态构建，带 exec 模块 ——
FROM alpine:3.20

# 安装基础依赖（无 Go 版本指定，避免 apk 失败）
RUN apk add --no-cache \
    git \
    gcc \
    musl-dev \
    curl \
    tar \
    && go clean -modcache || true \
    && rm -rf /go/pkg/mod

# 下载并安装 Go 1.25（官方二进制，避免 apk 版本冲突）
ENV GO_VERSION=1.25.10
ENV GO_ARCH=amd64 
RUN curl -L https://go.dev/dl/go${GO_VERSION}.linux-${GO_ARCH}.tar.gz -o /tmp/go.tar.gz \
    && tar -C /usr/local -xzf /tmp/go.tar.gz \
    && rm /tmp/go.tar.gz \
    && export PATH="/usr/local/go/bin:${PATH}"

# 安装 xcaddy 并构建 Caddy（用最新 Go）
RUN go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest \
    && xcaddy build v2.10.2 \
        --with github.com/abiosoft/caddy-exec \
        --with github.com/caddyserver/forwardproxy \
        --output /usr/bin/caddy \
    && chmod +x /usr/bin/caddy

# 清理所有（最小化镜像）
RUN apk del git gcc musl-dev curl tar \
    && rm -rf /usr/local/go /root/go /root/.cache /go/pkg/mod

# 复制配置文件和脚本
COPY Caddyfile /etc/caddy/Caddyfile
COPY vmess.sh /usr/local/bin/vmess.sh
RUN chmod +x /usr/local/bin/vmess.sh

EXPOSE 80

CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
