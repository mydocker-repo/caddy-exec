# —— 修复版：Alpine 3.22 + Go 1.25 + 静态构建，带 exec 模块 ——
FROM alpine:3.22

# 安装编译依赖（Go 1.25 已内置）
RUN apk add --no-cache \
    git \
    go=1.25.* \
    gcc \
    musl-dev \
    && go clean -modcache \
    && go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest \
    && xcaddy build v2.10.2 \
        --with github.com/abiosoft/caddy-exec \
        --with github.com/caddyserver/forwardproxy \
        --output /usr/bin/caddy \
    && chmod +x /usr/bin/caddy \
    && apk del git go gcc musl-dev \
    && rm -rf /root/go /root/.cache /go/pkg/mod

# 复制配置文件和脚本
COPY Caddyfile /etc/caddy/Caddyfile
COPY vmess.sh /usr/local/bin/vmess.sh
RUN chmod +x /usr/local/bin/vmess.sh

EXPOSE 80

CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
