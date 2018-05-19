#!make
.PHONY: run stop start build app-build docker-build help restart
.DEFAULT_GOAL= help

# - name of the Stack. Default is "rails".
STACK_NAME := "rails"

# Run the application in production mode.
run:
	docker-compose -p ${STACK_NAME} -f docker-compose.yml -f docker-compose.override.yml up -d && \
	make app-build

# Stop the application.
stop:
	docker-compose -p ${STACK_NAME} -f docker-compose.yml -f docker-compose.dev.yml -f docker-compose.override.yml down ${ARGS}

# Start the application in development mode.
start:
	docker-compose -p ${STACK_NAME} -f docker-compose.yml -f docker-compose.dev.yml -f docker-compose.override.yml up ${ARGS }

# Restart the application in development mode.
restart:
	make stop && \
	rm tmp/pids/* || true && \
	make start ${ARGS}

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
	docker-compose -p ${STACK_NAME} run web bundle install --jobs 20 && \
	docker-compose -p ${STACK_NAME} down && \
	docker image prune -f

# Execute the required commands in order to set up the app. The stack must be running and ready for this command.
app-build:
	docker-compose -p ${STACK_NAME} exec web rake db:create && \
	docker-compose -p ${STACK_NAME} exec web rake db:migrate

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
