
build: ## Build the app
	docker-compose -f docker-compose.dev.yaml stop ;\
	docker-compose -f docker-compose.dev.yaml build

rebuild: ## Attempt to rebuild the app without cache
	docker-compose -f docker-compose.dev.yaml rm --stop --force ;\
	docker-compose -f docker-compose.dev.yaml build --force-rm --no-cache

buildall: ## Build the entire rack
	docker-compose -f docker-compose.dev.yaml stop ;\
	docker-compose -f docker-compose.dev.yaml build

rebuildall: ## Attempt to rebuild the entire rack without cache
	docker-compose -f docker-compose.dev.yaml rm --stop --force ;\
	docker-compose -f docker-compose.dev.yaml build --force-rm --no-cache

start: ## Start the dev cluster
	docker-compose -f docker-compose.dev.yaml up

run: ## Start the development cluster in detached mode
	docker-compose -f docker-compose.dev.yaml up -d

stop: ## Attempt to stop the dev cluster
	docker-compose -f docker-compose.dev.yaml stop

kill: ## Attempt to kill the dev cluster
	docker-compose -f docker-compose.dev.yaml kill

nuke: ## Kill and Remove defined containers
	docker-compose -f docker-compose.dev.yaml rm --force --stop

runinstall: ## run composer install on the running app image - This is probably needed
	docker-compose -f docker-compose.dev.yaml exec app /bin/sh -c "composer install"

connect: ## Attempt to connect to the app on the development cluster
	docker-compose -f docker-compose.dev.yaml exec app /bin/sh

watchlogs: ## Watch the logs
	docker-compose -f docker-compose.dev.yaml logs -f app

.PHONY: help

help: ## Helping devs since 2016
	@cat $(MAKEFILE_LIST) | grep -e "^[a-zA-Z_\-]*: *.*## *" | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@echo "For additional commands have a look at the README"
