# 営業日報システム - プロジェクトガイド

## プロジェクト概要

営業担当者が日々の営業活動を報告し、上長がフィードバックを行うための日報管理システム。

### 主要機能
- 日報管理（作成・編集・提出・確認）
- 顧客訪問記録（1日報に複数件登録可能）
- Problem/Plan管理（課題・相談、明日やること）
- 上長コメント機能
- 顧客マスタ・営業マスタ管理

### ユーザー種別
- **一般営業**: 自分の日報を作成・閲覧・編集
- **上長**: 部下の日報を閲覧・コメント・確認、マスタ管理

## ドキュメント構成

```
docs/
├── requirements-definition.md   # 要件定義書・ER図
├── screen-definition.md         # 画面定義書（9画面）
├── api-specification.md         # API仕様書（27エンドポイント）
└── test-specification.md        # テスト仕様書（53ケース）
```

## データモデル

### 主要テーブル
| テーブル | 説明 |
|---------|------|
| SALES_PERSON | 営業担当者マスタ |
| CUSTOMER | 顧客マスタ |
| DAILY_REPORT | 日報 |
| VISIT_RECORD | 訪問記録 |
| PROBLEM | 課題・相談 |
| PLAN | 明日やること |
| COMMENT | 上長コメント |

### リレーション
- DAILY_REPORT : VISIT_RECORD = 1 : N
- DAILY_REPORT : PROBLEM = 1 : 0..1
- DAILY_REPORT : PLAN = 1 : 0..1
- PROBLEM/PLAN : COMMENT = 1 : N

@docs/requirements-definition.md

## API設計

### ベースURL
```
https://api.example.com/v1
```

### 認証
- Bearer Token (JWT)
- ヘッダー: `Authorization: Bearer {token}`

### 主要エンドポイント
| カテゴリ | エンドポイント | 説明 |
|---------|---------------|------|
| 認証 | POST /auth/login | ログイン |
| 日報 | GET /reports | 日報一覧 |
| 日報 | POST /reports | 日報作成 |
| 日報 | GET /reports/{id} | 日報詳細 |
| コメント | POST /problems/{id}/comments | コメント追加 |

@docs/api-specification.md

## 画面構成

| 画面ID | 画面名 | 概要 |
|--------|--------|------|
| SCR-001 | ログイン画面 | 認証 |
| SCR-010 | ダッシュボード | 日報一覧（ホーム） |
| SCR-020 | 日報作成画面 | 訪問記録・Problem・Plan入力 |
| SCR-022 | 日報詳細画面 | 閲覧・コメント |
| SCR-030 | 顧客マスタ一覧 | 顧客管理 |
| SCR-040 | 営業マスタ一覧 | 営業担当者管理（上長のみ） |

@docs/screen-definition.md

## ビジネスルール

### 日報ステータス遷移
```
draft（下書き） → submitted（提出済み） → confirmed（確認済み）
```

### 権限ルール
- 一般営業は自分の日報のみ閲覧・編集可能
- 上長は部下の日報を閲覧・コメント可能
- 確認済み日報は編集不可
- 訪問記録がある顧客は削除不可
- 日報がある営業担当者は削除不可

### バリデーションルール
- 1人1日1日報（重複不可）
- 訪問記録は最低1件必須（提出時）
- Problem/Plan: 最大2000文字
- 訪問内容: 最大1000文字
- コメント: 最大500文字

## 開発ガイドライン

### コーディング規約
- 言語: TypeScript推奨
- フォーマッタ: Prettier
- リンター: ESLint

### コミットメッセージ
```
feat: 新機能追加
fix: バグ修正
docs: ドキュメント更新
refactor: リファクタリング
test: テスト追加・修正
```

### ブランチ戦略
```
main          # 本番環境
├── develop   # 開発環境
    ├── feature/xxx  # 機能開発
    └── fix/xxx      # バグ修正
```

### コミット・プッシュ運用
- 作業の区切りごとに適宜コミットする
- 機能単位、バグ修正単位でこまめにコミットを行う
- コミット後はリモートリポジトリへプッシュする
- 長時間のローカル作業を避け、チーム間での変更共有を促進する

## テスト

### テストケース概要
- 機能テスト: 43ケース
- 非機能テスト: 10ケース（セキュリティ、性能、UI）
- 合計: 53ケース

### 重点テスト項目
- 認証・認可（権限チェック）
- 日報のCRUDとステータス遷移
- 上長コメント機能
- SQLインジェクション・XSS対策

@docs/test-specification.md

## 環境変数

```env
# Database
DATABASE_URL=postgresql://user:pass@localhost:5432/sales_report

# JWT
JWT_SECRET=your-secret-key
JWT_EXPIRES_IN=24h

# Server
PORT=3000
NODE_ENV=development
```

## よく使うコマンド

```bash
# 開発サーバー起動
npm run dev

# ビルド
npm run build

# テスト実行
npm run test

# リント
npm run lint

# マイグレーション
npm run migrate
```
