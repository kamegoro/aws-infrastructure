.PHONY: up down logs

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
