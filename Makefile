.PHONY: help build up down logs test clean k8s-deploy

help:
	@echo "Uso: make <target>"
	@echo ""
	@echo "Targets disponibles:"
	@echo "  build       Construye todas las imágenes"
	@echo "  up          Inicia servicios en desarrollo"
	@echo "  down        Detiene todos los servicios"
	@echo "  logs        Sigue los logs de todos los servicios"
	@echo "  test        Construye, inicia y verifica los contenedores"
	@echo "  clean       Limpia contenedores e imágenes"
	@echo "  prod        Inicia en modo producción"
	@echo "  k8s-deploy  Despliega en Kubernetes (local)"

build:
	docker compose build

up:
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f

test: build
	docker compose up -d
	@echo "Esperando que los servicios estén listos..."
	@sleep 5
	@curl -sf http://localhost:8080/api/health && echo "API OK" || echo "API FAIL"
	@curl -sf http://localhost:8080/ > /dev/null && echo "Web OK" || echo "Web FAIL"
	docker compose down

prod:
	docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d

clean:
	docker compose down -v --rmi all --remove-orphans

k8s-deploy:
	kubectl apply -f k8s/
