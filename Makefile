TF_DIR := terraform/envs/local

.PHONY: up down logs tf-init tf-plan tf-apply tf-destroy tf-fmt tf-validate tf-output

## MiniStackを起動する
up:
	docker compose up -d
	@echo "Waiting for MiniStack to be healthy..."
	@until [ "$$(docker inspect -f '{{.State.Health.Status}}' aws-infra-ministack 2>/dev/null)" = "healthy" ]; do sleep 2; done
	@echo "MiniStack is ready."

## MiniStackを停止する（.localstack/配下の状態は保持）
down:
	docker compose down

## MiniStackのログを追跡する
logs:
	docker compose logs -f ministack

## ローカル環境のTerraformを初期化する
tf-init:
	cd $(TF_DIR) && terraform init

## ローカル環境のplanを表示する
tf-plan:
	cd $(TF_DIR) && terraform plan

## MiniStackに対してローカル環境をapplyする
tf-apply:
	cd $(TF_DIR) && terraform apply

## ローカル環境をdestroyする
tf-destroy:
	cd $(TF_DIR) && terraform destroy

## すべてのTerraformファイルをフォーマットする
tf-fmt:
	terraform fmt -recursive

## ローカル環境の設定をvalidateする
tf-validate:
	cd $(TF_DIR) && terraform validate

## ローカル環境の出力を表示する
tf-output:
	cd $(TF_DIR) && terraform output
