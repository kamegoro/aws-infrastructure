SHELL := /bin/bash

TF_DIR := terraform/envs/local

.PHONY: up down logs tf-init tf-plan tf-apply tf-destroy tf-fmt tf-validate tf-output tflint tfsec sync-frontend e2e

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
## MiniStackのS3 Public Access Blockのdestroyに関する既知の制約
## (README参照)の回避策として、destroy前にstateからリソースを除外する
tf-destroy:
	cd $(TF_DIR) && terraform state rm module.static_site.aws_s3_bucket_public_access_block.frontend 2>/dev/null; \
	terraform destroy $(TF_DESTROY_ARGS)

## すべてのTerraformファイルをフォーマットする
tf-fmt:
	terraform fmt -recursive

## ローカル環境の設定をvalidateする
tf-validate:
	cd $(TF_DIR) && terraform validate

## ローカル環境の出力を表示する
tf-output:
	cd $(TF_DIR) && terraform output

## tflintで静的解析する
tflint:
	tflint --init
	tflint --recursive

## tfsecでセキュリティ面の静的解析をする
tfsec:
	tfsec terraform --config-file .tfsec/config.yml

## 静的アセットをMiniStackのS3バケットにアップロードする (例: make sync-frontend FRONTEND_DIR=../task-canvas/frontend/out)
sync-frontend:
	./scripts/sync-frontend.sh $(FRONTEND_DIR)

## MiniStack起動からapply・フロントエンド資産sync・E2Eテスト・destroy・停止までを一括実行する
## 例: make e2e \
##       FRONTEND_DIR=../task-canvas/frontend/out \
##       E2E_DIR=../task-canvas-e2e \
##       E2E_CMD="mvn test -Denv=ministack" \
##       DB_PASSWORD=<パスワード>
##   - FRONTEND_DIR: 指定した場合のみ sync-frontend を実行する
##   - E2E_DIR / E2E_CMD: 指定した場合のみ E2E テストを実行する
##     - terraform outputs から Hoplite 用の環境変数を生成して渡す
##     - DB_PASSWORD: Secrets Manager に登録した task_canvas ユーザーのパスワード
##   - E2Eテストの成否に関わらず、最後にtf-destroy/downでクリーンアップする
e2e: up
	cd $(TF_DIR) && terraform apply -auto-approve
	@if [ -n "$(FRONTEND_DIR)" ]; then $(MAKE) sync-frontend FRONTEND_DIR=$(FRONTEND_DIR); fi
	@status=0; \
	if [ -n "$(E2E_CMD)" ]; then \
		( set -a; \
		  source <(./scripts/tf-outputs-ministack-env.sh); \
		  export TASK_CANVAS__DB__PASSWORD="$(DB_PASSWORD)"; \
		  set +a; \
		  cd $(E2E_DIR) && $(E2E_CMD) ) || status=$$?; \
	fi; \
	$(MAKE) tf-destroy TF_DESTROY_ARGS=-auto-approve; \
	$(MAKE) down; \
	exit $$status
