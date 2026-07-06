# DockerTest

Proyecto demo de arquitectura Docker con Nginx, Node.js, monitoreo y despliegue multi-entorno.

## Arquitectura

```
┌─────────────────────────────────────────────────────┐
│                    Cliente HTTP                      │
└──────────────────────┬──────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────┐
│                  Nginx (Reverse Proxy)                │
│  · Servir contenido estático (index.html)            │
│  · Proxy inverso hacia la API (/api/*)               │
│  · Compresión gzip                                   │
│  · Cache de archivos estáticos                        │
│  · Rate limiting                                      │
│  · Security headers                                   │
└───────────┬───────────────────────────┬──────────────┘
            │                           │
            ▼                           ▼
┌──────────────────────┐   ┌──────────────────────────┐
│  index.html (estático)│   │  API Node.js / Express    │
│  Servido por Nginx   │   │  · /api/health           │
│  /usr/share/nginx/   │   │  · /api/info             │
│  html/index.html     │   │  · /api/message          │
│                      │   │  · /api/metrics          │
│                      │   │  (Prometheus metrics)    │
└──────────────────────┘   └──────────┬───────────────┘
                                       │
                              ┌────────▼────────┐
                              │  Prometheus      │
                              │  (métricas)      │
                              └────────┬────────┘
                                       │
                              ┌────────▼────────┐
                              │  Grafana         │
                              │  (dashboard)     │
                              └─────────────────┘
```

## Stack

| Capa         | Tecnología                         |
|-------------|-----------------------------------|
| Frontend    | HTML + CSS (estático)             |
| Backend     | Node.js 22 + Express              |
| Proxy       | Nginx 1.27-alpine                 |
| Contenedores| Docker + Docker Compose           |
| Orquestación| Kubernetes (manifests incluidos)  |
| Monitoreo   | Prometheus + Grafana + Loki       |
| CI/CD       | GitHub Actions                    |

## Estructura del proyecto

```
DockerTest/
├── api/                        # Backend Node.js
│   ├── src/
│   │   └── index.js            # Servidor Express con endpoints y métricas
│   ├── Dockerfile              # Dockerfile multi-stage, non-root user, HEALTHCHECK
│   └── package.json            # Dependencias
├── nginx/
│   └── nginx.conf              # Config personalizada (gzip, caching, seguridad, proxy)
├── k8s/                        # Manifests de Kubernetes
│   ├── deployment.yaml         # Deployments: web (2 réplicas) + api (2 réplicas)
│   ├── service.yaml            # Services: ClusterIP para web y api
│   └── ingress.yaml            # Ingress con nginx-ingress
├── monitoring/                 # Stack de observabilidad
│   ├── prometheus/
│   │   └── prometheus.yml      # Config de scrape
│   ├── grafana/
│   │   └── provisioning/       # Datasources y dashboards automáticos
│   └── loki/
│       └── loki-config.yml     # Config de Loki
├── .github/workflows/
│   └── docker-html-test.yml    # CI/CD: lint, build, test, security scan
├── Dockerfile                  # Dockerfile multi-stage para Nginx
├── docker-compose.yml          # Orquestación principal (web + api)
├── docker-compose.override.yml # Override para desarrollo (hot-reload)
├── docker-compose.prod.yml     # Override para producción
├── docker-compose.monitoring.yml # Stack de monitoreo
├── Makefile                    # Automatización de comandos
├── index.html                  # Página estática
└── .dockerignore               # Ignorar archivos en build
```

## Uso rápido

### Desarrollo

```bash
# Construir e iniciar servicios
make up

# Ver logs
make logs

# Probar endpoints
curl http://localhost:8080/              # Página estática
curl http://localhost:8080/api/health    # Health check
curl http://localhost:8080/api/info      # Info de la API
curl http://localhost:8080/api/message   # Mensaje
curl http://localhost:8080/api/metrics   # Métricas Prometheus

# Detener servicios
make down
```

### Producción

```bash
make prod
```

### Limpiar

```bash
make clean
```

### Monitoreo

```bash
docker compose -f docker-compose.monitoring.yml up -d
```

| Servicio   | URL                        |
|-----------|----------------------------|
| Grafana   | http://localhost:3001      |
| Prometheus| http://localhost:9090      |

Credenciales Grafana por defecto: `admin / admin`

### Kubernetes

```bash
make k8s-deploy
```

## Endpoints de la API

| Método | Ruta           | Descripción                        |
|--------|----------------|-----------------------------------|
| GET    | /api/health    | Health check (usado por Docker/K8s)|
| GET    | /api/info      | Información del servidor          |
| GET    | /api/message   | Mensaje de prueba                 |
| GET    | /api/metrics   | Métricas en formato Prometheus    |

## CI/CD

El pipeline de GitHub Actions ejecuta:

1. **Lint** — Validación de Dockerfile con Hadolint y docker-compose config
2. **Build & Test** — Construcción de imágenes, health checks, verificación de endpoints y métricas
3. **Security Scan** — Escaneo de vulnerabilidades con Trivy + subida de resultados SARIF

## Mejores prácticas aplicadas

- **Multi-stage build** — Imágenes más pequeñas y seguras
- **Non-root user** — Menor superficie de ataque en contenedores
- **HEALTHCHECK** — Los contenedores reportan su estado al orquestador
- **Readiness/Liveness probes** — Para Kubernetes
- **Rate limiting** — Protección contra abusos en la API
- **Security headers** — Headers HTTP de seguridad
- **Compresión gzip** — Mejor rendimiento de carga
- **Caching de estáticos** — Reducción de latencia
- **Logging estructurado** — Con Loki + Promtail
- **Métricas** — Prometheus + Grafana para observabilidad
- **Separación por entornos** — Dev (hot-reload) vs Producción
- **Variables de entorno** — Configuración parametrizable
