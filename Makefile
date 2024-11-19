# Variables
APP_NAME := chatwoot
RAILS_ENV ?= development

# Targets
setup:
	gem install bundler
	bundle install
	pnpm install

db_create:
	RAILS_ENV=$(RAILS_ENV) bundle exec rails db:create

db_migrate:
	RAILS_ENV=$(RAILS_ENV) bundle exec rails db:migrate

db_seed:
	RAILS_ENV=$(RAILS_ENV) bundle exec rails db:seed

db_reset:
	RAILS_ENV=$(RAILS_ENV) bundle exec rails db:reset

db:
	RAILS_ENV=$(RAILS_ENV) bundle exec rails db:chatwoot_prepare

console:
	RAILS_ENV=$(RAILS_ENV) bundle exec rails console

server:
	RAILS_ENV=$(RAILS_ENV) bundle exec rails server -b 0.0.0.0 -p 3000

burn:
	bundle && pnpm install

run:
	@if [ -f ./.overmind.sock ]; then \
		echo "Overmind is already running. Use 'make force_run' to start a new instance."; \
	else \
		overmind start -f Procfile.dev; \
	fi

force_run:
	rm -f ./.overmind.sock
	overmind start -f Procfile.dev

debug:
	overmind connect backend

debug_worker:
	overmind connect worker

docker: 
	docker build -t $(APP_NAME) -f ./docker/Dockerfile .


build-and-push: ## build and push docker
	sudo docker build . -f Dockerfile -t hermes.azurecr.io/chatwoot-v3150 --build-arg AKS=$(AKS) && \
	sudo docker push hermes.azurecr.io/chatwoot-v3150

deploy: ## deploy to azure container app
	@az containerapp update \
  --name chatwoot-v3150 \
  --resource-group hermes-group \
  --image hermes.azurecr.io/chatwoot-v3150:latest \
  --set-env-vars VERSION="$(VERSION)"

build-and-push-worker: ## build and push docker
	sudo docker build . -f worker.Dockerfile -t hermes.azurecr.io/chatwoot-v3150-worker --build-arg AKS=$(AKS) && \
	sudo docker push hermes.azurecr.io/chatwoot-v3150-worker

deploy-worker: ## deploy to azure container app
	@az containerapp update \
  --name chatwoot-v3150-worker \
  --resource-group hermes-group \
  --image hermes.azurecr.io/chatwoot-v3150:latest \
  --set-env-vars VERSION="$(VERSION)"

.PHONY: setup db_create db_migrate db_seed db_reset db console server burn docker run force_run debug debug_worker
