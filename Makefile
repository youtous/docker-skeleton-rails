#!make
.PHONY: run stop start build app-build docker-build help restart create
.DEFAULT_GOAL= help

# - name of the Stack. Default is "rails-app".
STACK_NAME := "rails-app"

# Run the application in production mode.
run:
	docker-compose -p ${STACK_NAME} -f docker-compose.yml -f docker-compose.override.yml up -d ${ARGS} && \
	make app-build && \
	make compile-assets

# Stop the application.
stop:
	docker-compose -p ${STACK_NAME} -f docker-compose.yml -f docker-compose.dev.yml -f docker-compose.override.yml down ${ARGS} && \
	rm tmp/pids/* || true

# Start the application in development mode.
start:
	docker-compose -p ${STACK_NAME} -f docker-compose.yml -f docker-compose.dev.yml -f docker-compose.override.yml up ${ARGS}

# Restart the application in production mode.
restart-production:
	make stop ${ARGS} && \
	make run ${ARGS}

# Restart the application in development mode.
restart:
	make stop ${ARGS} && \
	make start ${ARGS}

# Creates the Rails application. The name will be the same as the current directory.
create:
	make docker-build && \
	docker-compose -p ${STACK_NAME} run --rm web rails new .

# Build the application. This command will stop the stack.
build:
	make stop && \
	make docker-build && \
	make run && \
	make stop

# Build the docker stack, remove old images. This command will stop the stack.
docker-build:
	docker-compose -p ${STACK_NAME} down && \
	docker-compose build && \
	docker-compose -p ${STACK_NAME} run --rm web bundle install --jobs 20 --retry 5 && \
	docker-compose -p ${STACK_NAME} down && \
	docker image prune -f

# Execute the required commands in order to set up the app. The stack must be running and ready for this command.
app-build:
	docker-compose -p ${STACK_NAME} exec web rake db:create && \
	docker-compose -p ${STACK_NAME} exec web rake db:migrate

# Execute the required commands for compiling assets. The stack must be running in production and ready for this command.
compile-assets:
	docker-compose -p ${STACK_NAME} exec web rake assets:clean && \
	docker-compose -p ${STACK_NAME} exec web rake assets:precompile

# Show this help prompt.
help:
	@ echo
	@ echo '  Usage:'
	@ echo ''
	@ echo '    make <target> [flags...]'
	@ echo ''
	@ echo '  Targets:'
	@ echo ''
	@ awk '/^#/{ comment = substr($$0,3) } comment && /^[a-zA-Z][a-zA-Z0-9_-]+ ?:/{ print "   ", $$1, comment }' $(MAKEFILE_LIST) | column -t -s ':' | sort
	@ echo ''
	@ echo '  Flags:'
	@ echo ''
	@ awk '/^#/{ comment = substr($$0,3) } comment && /^[a-zA-Z][a-zA-Z0-9_-]+ ?\?=/{ print "   ", $$1, $$2, comment }' $(MAKEFILE_LIST) | column -t -s '?=' | sort
	@ echo ''
