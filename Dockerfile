FROM alpine:3.20

# 安装系统依赖 + 编译工具（一次性）
RUN apk add --no-cache \
    git \
    go \
    gcc \
    && go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest \
    && /root/go/bin/xcaddy build v2.10.2 \
        --with github.com/abiosoft/caddy-exec \
        --with github.com/caddyserver/forwardproxy \
    && mv caddy /usr/bin/caddy \
    && chmod +x /usr/bin/caddy \
    && apk del git go gcc musl-dev \
    && rm -rf /root/go /root/.cache

# 复制你的 Caddyfile 和 vmess.sh 脚本（下面示例用最稳的 exec 版）
COPY Caddyfile /etc/caddy/Caddyfile
COPY vmess.sh /usr/local/bin/vmess.sh
RUN chmod +x /usr/local/bin/vmess.sh

EXPOSE 80

CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
