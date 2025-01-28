# Variables
DOCKER_RUN = docker compose run --rm artisan
DOCKER_EXEC_APP = docker compose exec app
DOCKER_EXEC_MYAPP = docker exec myapp

.PHONY: help migrate-fresh migrate seed start-supervisor swagger-generate artisan

help:
	@echo "Available commands:"
	@echo "  make migrate-fresh     - Run migrations fresh and seed."
	@echo "  make migrate           - Run database migrations."
	@echo "  make seed              - Seed the database."
	@echo "  make start-supervisor  - Start Supervisor in app service."
	@echo "  make swagger-generate  - Generate Swagger docs."
	@echo "  make artisan cmd=...   - Run any php artisan command. example make artisan cmd='make:model Test'"

# Run migrate:fresh and seed
migrate-fresh:
	$(DOCKER_RUN) migrate:fresh --seed

# Run database migrations
migrate:
	$(DOCKER_RUN) migrate

# Seed the database
seed:
	$(DOCKER_RUN) db:seed

# Start Supervisor and reload its configuration
start-supervisor:
	$(DOCKER_EXEC_APP) supervisord -c /etc/supervisor/supervisord.conf
	$(DOCKER_EXEC_MYAPP) supervisorctl reread
	$(DOCKER_EXEC_MYAPP) supervisorctl update
	$(DOCKER_EXEC_MYAPP) supervisorctl start all

# Generate Swagger docs
swagger-generate:
	$(DOCKER_RUN) l5-swagger:generate

# Run any php artisan command
artisan:
	$(DOCKER_RUN) $(cmd)
