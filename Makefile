SHELL=/bin/bash
.PHONY: help publish test

help: ## Show this help
	@echo "Targets:"
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/\(.*\):.*##[ \t]*/    \1 ## /' | sort | column -t -s '##'

up: ## Start containers
	docker-compose up -d

down: ## Stops containers
	docker-compose down

restart: down up ## Restart containers

clear-db: ## Clears local db
	bash -c "rm -rf .docker"

build: ## Rebuild containers
	docker-compose build --no-cache

complete-restart: clear-db down up    ## Clear DB and restart containers

publish: ## Build and publish plugin to luarocks
	docker-compose run --rm kong bash -c "cd /kong-plugins && chmod +x publish.sh && ./publish.sh"
	docker-compose down

test: ## Run tests
	docker-compose run --rm kong bash -c "cd /kong && kong migrations up || kong migrations bootstrap && bin/busted /kong-plugins/spec -v"
	docker-compose down

dev-env: ## Creates a service (myservice) and attaches a plugin to it (upstream-selector)
	bash -c "curl -i -X POST --url http://localhost:8001/services/ --data 'name=testapi' --data 'protocol=http' --data 'host=mockbin' --data 'path=/request'"
	bash -c "curl -i -X POST --url http://localhost:8001/services/testapi/routes/ --data 'paths[]=/'"
	bash -c "curl -i -X POST --url http://localhost:8001/services/testapi/plugins/ --data 'name=upstream-selector' --data 'config.header_name=X-Header'"
	bash -c "curl -i -X POST --url http://localhost:8001/upstreams --data 'name=mockbin2'"
	bash -c "curl -i -X POST --url http://localhost:8001/upstreams/mockbin2/targets --data 'target=mockbin2:8090'"

ping: ## Pings kong on localhost:8000
	bash -c "curl -i http://localhost:8000"

ssh: ## Pings kong on localhost:8000
	docker-compose run --rm kong bash

db: ## Access DB
	docker-compose run --rm kong bash -c "psql -h kong-database -U kong"
