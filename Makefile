TF_DIR := terraform/envs/local

.PHONY: up down logs tf-init tf-plan tf-apply tf-destroy tf-fmt tf-validate tf-output

## Start MiniStack
up:
	docker compose up -d
	@echo "Waiting for MiniStack to be healthy..."
	@until [ "$$(docker inspect -f '{{.State.Health.Status}}' aws-infra-ministack 2>/dev/null)" = "healthy" ]; do sleep 2; done
	@echo "MiniStack is ready."

## Stop MiniStack (keeps state under .localstack/)
down:
	docker compose down

## Follow MiniStack logs
logs:
	docker compose logs -f ministack

## Initialize the local Terraform environment
tf-init:
	cd $(TF_DIR) && terraform init

## Show the Terraform plan for the local environment
tf-plan:
	cd $(TF_DIR) && terraform plan

## Apply the local environment against MiniStack
tf-apply:
	cd $(TF_DIR) && terraform apply

## Destroy the local environment
tf-destroy:
	cd $(TF_DIR) && terraform destroy

## Format all Terraform files
tf-fmt:
	terraform fmt -recursive

## Validate the local environment configuration
tf-validate:
	cd $(TF_DIR) && terraform validate

## Show outputs from the local environment
tf-output:
	cd $(TF_DIR) && terraform output
