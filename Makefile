ENV_DIR := terraform/envs/local

.PHONY: up down logs init plan apply destroy fmt validate output

## Start LocalStack
up:
	docker compose up -d
	@echo "Waiting for LocalStack to be healthy..."
	@until [ "$$(docker inspect -f '{{.State.Health.Status}}' aws-infra-localstack 2>/dev/null)" = "healthy" ]; do sleep 2; done
	@echo "LocalStack is ready."

## Stop LocalStack (keeps state under .localstack/)
down:
	docker compose down

## Follow LocalStack logs
logs:
	docker compose logs -f localstack

init:
	terraform -chdir=$(ENV_DIR) init

plan:
	terraform -chdir=$(ENV_DIR) plan

apply:
	terraform -chdir=$(ENV_DIR) apply

destroy:
	terraform -chdir=$(ENV_DIR) destroy

fmt:
	terraform fmt -recursive

validate:
	terraform -chdir=$(ENV_DIR) validate

output:
	terraform -chdir=$(ENV_DIR) output
