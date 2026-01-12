# 営業日報システム - Makefile
# ==================================

.PHONY: help install dev build test lint clean deploy deploy-prod deploy-preview db-push db-migrate db-studio

# デフォルトターゲット
help:
	@echo "営業日報システム - 利用可能なコマンド"
	@echo ""
	@echo "開発:"
	@echo "  make install      - 依存関係をインストール"
	@echo "  make dev          - 開発サーバーを起動"
	@echo "  make build        - プロジェクトをビルド"
	@echo ""
	@echo "テスト・品質:"
	@echo "  make test         - テストを実行"
	@echo "  make test-watch   - ウォッチモードでテスト実行"
	@echo "  make test-cov     - カバレッジ付きでテスト実行"
	@echo "  make lint         - ESLintを実行"
	@echo "  make lint-fix     - ESLintで自動修正"
	@echo "  make typecheck    - 型チェックを実行"
	@echo ""
	@echo "データベース:"
	@echo "  make db-push      - スキーマをDBに反映"
	@echo "  make db-migrate   - マイグレーションを実行"
	@echo "  make db-studio    - Prisma Studioを起動"
	@echo "  make db-generate  - Prisma Clientを生成"
	@echo ""
	@echo "デプロイ:"
	@echo "  make deploy       - Vercelにデプロイ (プレビュー)"
	@echo "  make deploy-prod  - Vercelに本番デプロイ"
	@echo "  make deploy-preview - Vercelにプレビューデプロイ"
	@echo ""
	@echo "その他:"
	@echo "  make clean        - ビルド成果物を削除"
	@echo "  make ci           - CI用チェック (lint, test, build)"

# ==================================
# 開発
# ==================================

install:
	npm ci

dev:
	npm run dev

build:
	npm run prisma:generate
	npm run build

# ==================================
# テスト・品質
# ==================================

test:
	npm run test

test-watch:
	npm run test:watch

test-cov:
	npm run test:coverage

lint:
	npm run lint

lint-fix:
	npm run lint:fix

typecheck:
	npx tsc --noEmit

# ==================================
# データベース
# ==================================

db-push:
	npm run db:push

db-migrate:
	npm run prisma:migrate

db-studio:
	npm run prisma:studio

db-generate:
	npm run prisma:generate

# ==================================
# デプロイ
# ==================================

# Vercelにプレビューデプロイ
deploy:
	vercel

# Vercelに本番デプロイ
deploy-prod:
	vercel --prod

# Vercelにプレビューデプロイ (エイリアス)
deploy-preview:
	vercel

# ==================================
# その他
# ==================================

clean:
	rm -rf dist
	rm -rf coverage
	rm -rf node_modules/.cache

# CI用チェック (lint, test, build)
ci: lint typecheck test build
	@echo "CI checks passed!"
