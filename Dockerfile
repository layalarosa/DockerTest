# Stage 1: build (placeholder for future build steps)
FROM alpine:3.20 AS build

WORKDIR /build
COPY index.html ./

# Stage 2: nginx runtime
FROM nginx:1.27-alpine

RUN addgroup -S appgroup && adduser -S appuser -G appgroup && \
    rm -f /etc/nginx/conf.d/default.conf && \
    mkdir -p /var/cache/nginx && \
    chown -R appuser:appgroup /var/cache/nginx /var/log/nginx /etc/nginx/nginx.conf && \
    touch /var/run/nginx.pid && \
    chown -R appuser:appgroup /var/run/nginx.pid

COPY --from=build /build/index.html /usr/share/nginx/html/index.html
COPY nginx/nginx.conf /etc/nginx/nginx.conf

USER appuser

EXPOSE 80
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:80/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
