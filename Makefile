setup:
	cp docker-compose.override.yml.dist docker-compose.override.yml && \
	cp .env.prod.dist .env.prod

build-dev:
	docker compose build app && docker compose build

build-prod:
	docker-compose -f docker-compose.yml -f docker-compose.production.yml build app && \
	docker-compose -f docker-compose.yml -f docker-compose.production.yml build

up-dev:
	docker compose up

up-prod:
	docker-compose -f docker-compose.yml -f docker-compose.production.yml --env-file .env.prod up
