# Variables
DOCKER_RUN = docker compose run --rm app
DOCKER_EXEC_APP = docker compose exec app
DOCKER_EXEC_MYAPP = docker exec myapp

.PHONY: help migrate-fresh migrate seed start-supervisor swagger-generate artisan npm-install npm-run-dev npm-run-build

help:
	@echo "Available commands:"
	@echo "  make migrate-fresh     - Run migrations fresh and seed."
	@echo "  make migrate           - Run database migrations."
	@echo "  make seed              - Seed the database."
	@echo "  make start-supervisor  - Start Supervisor in app service."
	@echo "  make swagger-generate  - Generate Swagger docs."
	@echo "  make artisan cmd=...   - Run any php artisan command. Example: make artisan cmd='make:model Test'"
	@echo "  make npm-install       - Install npm dependencies."
	@echo "  make npm-run-dev       - Run npm dev server."
	@echo "  make npm-run-build     - Build assets for production."
    @echo "  make npm cmd=...       - Install npm command. Example:make npm cmd='install package'"

# Run migrate:fresh and seed
migrate-fresh:
	$(DOCKER_RUN) php artisan migrate:fresh --seed

# Run database migrations
migrate:
	$(DOCKER_RUN) php artisan migrate

# Seed the database
seed:
	$(DOCKER_RUN) php artisan db:seed

# Start Supervisor and reload its configuration
start-supervisor:
	$(DOCKER_EXEC_APP) supervisord -c /etc/supervisor/supervisord.conf
	$(DOCKER_EXEC_MYAPP) supervisorctl reread
	$(DOCKER_EXEC_MYAPP) supervisorctl update
	$(DOCKER_EXEC_MYAPP) supervisorctl start all

# Generate Swagger docs
swagger-generate:
	$(DOCKER_RUN) php artisan l5-swagger:generate

# Run any php artisan command
artisan:
	$(DOCKER_RUN) php artisan $(cmd)

# Run npm install
npm-install:
	$(DOCKER_EXEC_APP) npm install

# Run npm dev server
npm-run-dev:
	$(DOCKER_EXEC_APP) npm run dev

# Build assets for production
npm-run-build:
	$(DOCKER_EXEC_APP) npm run build

# Run Npm command
npm:
	$(DOCKER_EXEC_APP) npm $(cmd)

