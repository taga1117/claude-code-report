# 営業日報システム API仕様書

## 1. 概要

### 1.1 基本情報

| 項目 | 値 |
|------|-----|
| ベースURL | `https://api.example.com/v1` |
| プロトコル | HTTPS |
| データ形式 | JSON |
| 文字コード | UTF-8 |
| 認証方式 | Bearer Token (JWT) |

### 1.2 共通ヘッダー

**リクエスト**
```
Content-Type: application/json
Authorization: Bearer {token}
```

**レスポンス**
```
Content-Type: application/json
```

### 1.3 共通レスポンス形式

**成功時**
```json
{
  "success": true,
  "data": { ... }
}
```

**エラー時**
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "エラーメッセージ"
  }
}
```

### 1.4 共通エラーコード

| HTTPステータス | エラーコード | 説明 |
|---------------|-------------|------|
| 400 | BAD_REQUEST | リクエスト形式不正 |
| 401 | UNAUTHORIZED | 認証エラー |
| 403 | FORBIDDEN | 権限エラー |
| 404 | NOT_FOUND | リソースが存在しない |
| 409 | CONFLICT | 競合エラー（重複など） |
| 422 | VALIDATION_ERROR | バリデーションエラー |
| 500 | INTERNAL_ERROR | サーバー内部エラー |

---

## 2. API一覧

| カテゴリ | メソッド | エンドポイント | 説明 |
|---------|---------|---------------|------|
| 認証 | POST | /auth/login | ログイン |
| 認証 | POST | /auth/logout | ログアウト |
| 認証 | GET | /auth/me | ログインユーザー情報取得 |
| 日報 | GET | /reports | 日報一覧取得 |
| 日報 | POST | /reports | 日報作成 |
| 日報 | GET | /reports/{id} | 日報詳細取得 |
| 日報 | PUT | /reports/{id} | 日報更新 |
| 日報 | DELETE | /reports/{id} | 日報削除 |
| 日報 | PATCH | /reports/{id}/status | 日報ステータス更新 |
| 訪問記録 | POST | /reports/{id}/visits | 訪問記録追加 |
| 訪問記録 | PUT | /reports/{id}/visits/{visitId} | 訪問記録更新 |
| 訪問記録 | DELETE | /reports/{id}/visits/{visitId} | 訪問記録削除 |
| Problem | PUT | /reports/{id}/problem | Problem更新 |
| Plan | PUT | /reports/{id}/plan | Plan更新 |
| コメント | POST | /problems/{id}/comments | Problemへコメント追加 |
| コメント | POST | /plans/{id}/comments | Planへコメント追加 |
| 顧客 | GET | /customers | 顧客一覧取得 |
| 顧客 | POST | /customers | 顧客登録 |
| 顧客 | GET | /customers/{id} | 顧客詳細取得 |
| 顧客 | PUT | /customers/{id} | 顧客更新 |
| 顧客 | DELETE | /customers/{id} | 顧客削除 |
| 営業 | GET | /sales-persons | 営業一覧取得 |
| 営業 | POST | /sales-persons | 営業登録 |
| 営業 | GET | /sales-persons/{id} | 営業詳細取得 |
| 営業 | PUT | /sales-persons/{id} | 営業更新 |
| 営業 | DELETE | /sales-persons/{id} | 営業削除 |

---

## 3. 認証 API

### 3.1 ログイン

ユーザー認証を行い、アクセストークンを取得する。

**エンドポイント**
```
POST /auth/login
```

**リクエスト（認証不要）**
```json
{
  "email": "yamada@example.com",
  "password": "password123"
}
```

| パラメータ | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| email | string | ○ | メールアドレス |
| password | string | ○ | パスワード |

**レスポンス（200 OK）**
```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIs...",
    "expires_at": "2026-01-13T09:00:00Z",
    "user": {
      "sales_person_id": 1,
      "name": "山田太郎",
      "email": "yamada@example.com",
      "department": "営業1課",
      "is_manager": false
    }
  }
}
```

**エラーレスポンス（401 Unauthorized）**
```json
{
  "success": false,
  "error": {
    "code": "INVALID_CREDENTIALS",
    "message": "メールアドレスまたはパスワードが正しくありません"
  }
}
```

---

### 3.2 ログアウト

アクセストークンを無効化する。

**エンドポイント**
```
POST /auth/logout
```

**レスポンス（200 OK）**
```json
{
  "success": true,
  "data": {
    "message": "ログアウトしました"
  }
}
```

---

### 3.3 ログインユーザー情報取得

現在ログイン中のユーザー情報を取得する。

**エンドポイント**
```
GET /auth/me
```

**レスポンス（200 OK）**
```json
{
  "success": true,
  "data": {
    "sales_person_id": 1,
    "name": "山田太郎",
    "email": "yamada@example.com",
    "department": "営業1課",
    "manager_id": 3,
    "manager_name": "田中一郎",
    "is_manager": false
  }
}
```

---

## 4. 日報 API

### 4.1 日報一覧取得

日報の一覧を取得する。一般営業は自分の日報のみ、上長は部下の日報も取得可能。

**エンドポイント**
```
GET /reports
```

**クエリパラメータ**

| パラメータ | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| date_from | date | - | 検索開始日（YYYY-MM-DD） |
| date_to | date | - | 検索終了日（YYYY-MM-DD） |
| sales_person_id | integer | - | 営業担当者ID（上長のみ指定可） |
| status | string | - | ステータス（draft/submitted/confirmed） |
| page | integer | - | ページ番号（デフォルト: 1） |
| per_page | integer | - | 1ページあたり件数（デフォルト: 20、最大: 100） |

**レスポンス（200 OK）**
```json
{
  "success": true,
  "data": {
    "reports": [
      {
        "report_id": 1,
        "report_date": "2026-01-12",
        "sales_person_id": 1,
        "sales_person_name": "山田太郎",
        "status": "submitted",
        "visit_count": 3,
        "created_at": "2026-01-12T09:00:00Z",
        "updated_at": "2026-01-12T18:00:00Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "per_page": 20,
      "total_pages": 5,
      "total_count": 98
    }
  }
}
```

---

### 4.2 日報作成

新規日報を作成する。

**エンドポイント**
```
POST /reports
```

**リクエスト**
```json
{
  "report_date": "2026-01-12",
  "status": "draft",
  "visits": [
    {
      "customer_id": 1,
      "visit_time": "10:00",
      "visit_content": "新製品の提案を実施。担当者は興味を示している。"
    },
    {
      "customer_id": 2,
      "visit_time": "14:00",
      "visit_content": "契約更新の打ち合わせ。来月中に回答予定。"
    }
  ],
  "problem": {
    "content": "顧客Aの予算が厳しく、値引き交渉が必要。どの程度まで対応可能か相談したい。"
  },
  "plan": {
    "content": "・顧客Aへ再提案\n・顧客Bへ電話フォロー"
  }
}
```

| パラメータ | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| report_date | date | ○ | 報告日（YYYY-MM-DD） |
| status | string | ○ | ステータス（draft/submitted） |
| visits | array | ○ | 訪問記録（最低1件） |
| visits[].customer_id | integer | ○ | 顧客ID |
| visits[].visit_time | time | - | 訪問時刻（HH:mm） |
| visits[].visit_content | string | ○ | 訪問内容（最大1000文字） |
| problem | object | - | Problem |
| problem.content | string | - | 課題・相談内容（最大2000文字） |
| plan | object | - | Plan |
| plan.content | string | - | 明日やること（最大2000文字） |

**レスポンス（201 Created）**
```json
{
  "success": true,
  "data": {
    "report_id": 1,
    "report_date": "2026-01-12",
    "sales_person_id": 1,
    "status": "draft",
    "created_at": "2026-01-12T09:00:00Z"
  }
}
```

**エラーレスポンス（409 Conflict）**
```json
{
  "success": false,
  "error": {
    "code": "DUPLICATE_REPORT",
    "message": "指定された日付の日報は既に存在します"
  }
}
```

---

### 4.3 日報詳細取得

日報の詳細情報を取得する。

**エンドポイント**
```
GET /reports/{id}
```

**パスパラメータ**

| パラメータ | 型 | 説明 |
|-----------|-----|------|
| id | integer | 日報ID |

**レスポンス（200 OK）**
```json
{
  "success": true,
  "data": {
    "report_id": 1,
    "report_date": "2026-01-12",
    "sales_person_id": 1,
    "sales_person_name": "山田太郎",
    "status": "submitted",
    "visits": [
      {
        "visit_id": 1,
        "customer_id": 1,
        "customer_name": "株式会社ABC",
        "visit_time": "10:00",
        "visit_content": "新製品の提案を実施。担当者は興味を示している。",
        "created_at": "2026-01-12T09:00:00Z"
      },
      {
        "visit_id": 2,
        "customer_id": 2,
        "customer_name": "株式会社XYZ",
        "visit_time": "14:00",
        "visit_content": "契約更新の打ち合わせ。来月中に回答予定。",
        "created_at": "2026-01-12T09:00:00Z"
      }
    ],
    "problem": {
      "problem_id": 1,
      "content": "顧客Aの予算が厳しく、値引き交渉が必要。",
      "comments": [
        {
          "comment_id": 1,
          "sales_person_id": 3,
          "sales_person_name": "田中一郎",
          "content": "10%までなら対応可能です。詳細は明日話しましょう。",
          "created_at": "2026-01-12T18:30:00Z"
        }
      ]
    },
    "plan": {
      "plan_id": 1,
      "content": "・顧客Aへ再提案\n・顧客Bへ電話フォロー",
      "comments": []
    },
    "created_at": "2026-01-12T09:00:00Z",
    "updated_at": "2026-01-12T18:00:00Z"
  }
}
```

---

### 4.4 日報更新

既存日報を更新する。下書き・提出済みステータスのみ更新可能。

**エンドポイント**
```
PUT /reports/{id}
```

**リクエスト**
```json
{
  "visits": [
    {
      "visit_id": 1,
      "customer_id": 1,
      "visit_time": "10:00",
      "visit_content": "新製品の提案を実施。担当者は興味を示している。次回訪問は来週予定。"
    }
  ],
  "problem": {
    "content": "顧客Aの予算が厳しく、値引き交渉が必要。"
  },
  "plan": {
    "content": "・顧客Aへ再提案（値引き込み）\n・顧客Bへ電話フォロー"
  }
}
```

**レスポンス（200 OK）**
```json
{
  "success": true,
  "data": {
    "report_id": 1,
    "updated_at": "2026-01-12T19:00:00Z"
  }
}
```

**エラーレスポンス（403 Forbidden）**
```json
{
  "success": false,
  "error": {
    "code": "CANNOT_EDIT_CONFIRMED",
    "message": "確認済みの日報は編集できません"
  }
}
```

---

### 4.5 日報削除

日報を削除する。下書きステータスのみ削除可能。

**エンドポイント**
```
DELETE /reports/{id}
```

**レスポンス（200 OK）**
```json
{
  "success": true,
  "data": {
    "message": "日報を削除しました"
  }
}
```

---

### 4.6 日報ステータス更新

日報のステータスを更新する。

**エンドポイント**
```
PATCH /reports/{id}/status
```

**リクエスト**
```json
{
  "status": "confirmed"
}
```

| パラメータ | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| status | string | ○ | 新しいステータス |

**ステータス遷移ルール**

| 現在のステータス | 遷移可能なステータス | 実行可能者 |
|-----------------|---------------------|-----------|
| draft | submitted | 本人のみ |
| submitted | confirmed | 上長のみ |

**レスポンス（200 OK）**
```json
{
  "success": true,
  "data": {
    "report_id": 1,
    "status": "confirmed",
    "updated_at": "2026-01-12T19:00:00Z"
  }
}
```

---

## 5. 訪問記録 API

### 5.1 訪問記録追加

日報に訪問記録を追加する。

**エンドポイント**
```
POST /reports/{id}/visits
```

**リクエスト**
```json
{
  "customer_id": 3,
  "visit_time": "16:00",
  "visit_content": "アフターフォローの訪問。特に問題なし。"
}
```

**レスポンス（201 Created）**
```json
{
  "success": true,
  "data": {
    "visit_id": 3,
    "customer_id": 3,
    "customer_name": "株式会社DEF",
    "visit_time": "16:00",
    "visit_content": "アフターフォローの訪問。特に問題なし。",
    "created_at": "2026-01-12T19:00:00Z"
  }
}
```

---

### 5.2 訪問記録更新

訪問記録を更新する。

**エンドポイント**
```
PUT /reports/{id}/visits/{visitId}
```

**リクエスト**
```json
{
  "customer_id": 3,
  "visit_time": "16:30",
  "visit_content": "アフターフォローの訪問。追加発注の相談あり。"
}
```

**レスポンス（200 OK）**
```json
{
  "success": true,
  "data": {
    "visit_id": 3,
    "updated_at": "2026-01-12T19:30:00Z"
  }
}
```

---

### 5.3 訪問記録削除

訪問記録を削除する。

**エンドポイント**
```
DELETE /reports/{id}/visits/{visitId}
```

**レスポンス（200 OK）**
```json
{
  "success": true,
  "data": {
    "message": "訪問記録を削除しました"
  }
}
```

---

## 6. Problem/Plan API

### 6.1 Problem更新

日報のProblemを更新する。

**エンドポイント**
```
PUT /reports/{id}/problem
```

**リクエスト**
```json
{
  "content": "顧客Aの予算が厳しく、値引き交渉が必要。上長に相談済み。"
}
```

**レスポンス（200 OK）**
```json
{
  "success": true,
  "data": {
    "problem_id": 1,
    "content": "顧客Aの予算が厳しく、値引き交渉が必要。上長に相談済み。",
    "updated_at": "2026-01-12T19:00:00Z"
  }
}
```

---

### 6.2 Plan更新

日報のPlanを更新する。

**エンドポイント**
```
PUT /reports/{id}/plan
```

**リクエスト**
```json
{
  "content": "・顧客Aへ再提案（10%値引き）\n・顧客Bへ電話フォロー\n・新規顧客リスト作成"
}
```

**レスポンス（200 OK）**
```json
{
  "success": true,
  "data": {
    "plan_id": 1,
    "content": "・顧客Aへ再提案（10%値引き）\n・顧客Bへ電話フォロー\n・新規顧客リスト作成",
    "updated_at": "2026-01-12T19:00:00Z"
  }
}
```

---

## 7. コメント API

### 7.1 Problemへコメント追加

Problemにコメントを追加する（上長のみ）。

**エンドポイント**
```
POST /problems/{id}/comments
```

**リクエスト**
```json
{
  "content": "10%までなら対応可能です。詳細は明日話しましょう。"
}
```

| パラメータ | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| content | string | ○ | コメント内容（最大500文字） |

**レスポンス（201 Created）**
```json
{
  "success": true,
  "data": {
    "comment_id": 1,
    "sales_person_id": 3,
    "sales_person_name": "田中一郎",
    "content": "10%までなら対応可能です。詳細は明日話しましょう。",
    "created_at": "2026-01-12T18:30:00Z"
  }
}
```

---

### 7.2 Planへコメント追加

Planにコメントを追加する（上長のみ）。

**エンドポイント**
```
POST /plans/{id}/comments
```

**リクエスト**
```json
{
  "content": "新規顧客リストは私が持っているものを共有します。"
}
```

**レスポンス（201 Created）**
```json
{
  "success": true,
  "data": {
    "comment_id": 2,
    "sales_person_id": 3,
    "sales_person_name": "田中一郎",
    "content": "新規顧客リストは私が持っているものを共有します。",
    "created_at": "2026-01-12T18:35:00Z"
  }
}
```

---

## 8. 顧客マスタ API

### 8.1 顧客一覧取得

顧客の一覧を取得する。

**エンドポイント**
```
GET /customers
```

**クエリパラメータ**

| パラメータ | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| keyword | string | - | 顧客名で検索 |
| page | integer | - | ページ番号（デフォルト: 1） |
| per_page | integer | - | 1ページあたり件数（デフォルト: 20） |

**レスポンス（200 OK）**
```json
{
  "success": true,
  "data": {
    "customers": [
      {
        "customer_id": 1,
        "customer_name": "株式会社ABC",
        "address": "東京都千代田区丸の内1-1-1",
        "phone": "03-1234-5678",
        "contact_person": "佐藤様",
        "created_at": "2026-01-01T00:00:00Z",
        "updated_at": "2026-01-01T00:00:00Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "per_page": 20,
      "total_pages": 3,
      "total_count": 45
    }
  }
}
```

---

### 8.2 顧客登録

新規顧客を登録する。

**エンドポイント**
```
POST /customers
```

**リクエスト**
```json
{
  "customer_name": "株式会社NEW",
  "address": "東京都港区六本木1-1-1",
  "phone": "03-9999-8888",
  "contact_person": "鈴木様"
}
```

| パラメータ | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| customer_name | string | ○ | 顧客名（最大100文字） |
| address | string | - | 住所（最大200文字） |
| phone | string | - | 電話番号 |
| contact_person | string | - | 担当者名（最大50文字） |

**レスポンス（201 Created）**
```json
{
  "success": true,
  "data": {
    "customer_id": 46,
    "customer_name": "株式会社NEW",
    "created_at": "2026-01-12T10:00:00Z"
  }
}
```

---

### 8.3 顧客詳細取得

顧客の詳細情報を取得する。

**エンドポイント**
```
GET /customers/{id}
```

**レスポンス（200 OK）**
```json
{
  "success": true,
  "data": {
    "customer_id": 1,
    "customer_name": "株式会社ABC",
    "address": "東京都千代田区丸の内1-1-1",
    "phone": "03-1234-5678",
    "contact_person": "佐藤様",
    "created_at": "2026-01-01T00:00:00Z",
    "updated_at": "2026-01-01T00:00:00Z"
  }
}
```

---

### 8.4 顧客更新

顧客情報を更新する。

**エンドポイント**
```
PUT /customers/{id}
```

**リクエスト**
```json
{
  "customer_name": "株式会社ABC",
  "address": "東京都千代田区丸の内2-2-2",
  "phone": "03-1234-5678",
  "contact_person": "高橋様"
}
```

**レスポンス（200 OK）**
```json
{
  "success": true,
  "data": {
    "customer_id": 1,
    "updated_at": "2026-01-12T10:00:00Z"
  }
}
```

---

### 8.5 顧客削除

顧客を削除する。訪問記録が存在する場合は削除不可。

**エンドポイント**
```
DELETE /customers/{id}
```

**レスポンス（200 OK）**
```json
{
  "success": true,
  "data": {
    "message": "顧客を削除しました"
  }
}
```

**エラーレスポンス（409 Conflict）**
```json
{
  "success": false,
  "error": {
    "code": "HAS_RELATED_RECORDS",
    "message": "訪問記録が存在するため削除できません"
  }
}
```

---

## 9. 営業マスタ API

### 9.1 営業一覧取得

営業担当者の一覧を取得する（上長のみ）。

**エンドポイント**
```
GET /sales-persons
```

**クエリパラメータ**

| パラメータ | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| keyword | string | - | 氏名で検索 |
| department | string | - | 部署で絞り込み |
| is_manager | boolean | - | 上長のみ取得 |
| page | integer | - | ページ番号（デフォルト: 1） |
| per_page | integer | - | 1ページあたり件数（デフォルト: 20） |

**レスポンス（200 OK）**
```json
{
  "success": true,
  "data": {
    "sales_persons": [
      {
        "sales_person_id": 1,
        "name": "山田太郎",
        "email": "yamada@example.com",
        "department": "営業1課",
        "manager_id": 3,
        "manager_name": "田中一郎",
        "is_manager": false,
        "created_at": "2026-01-01T00:00:00Z",
        "updated_at": "2026-01-01T00:00:00Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "per_page": 20,
      "total_pages": 2,
      "total_count": 25
    }
  }
}
```

---

### 9.2 営業登録

新規営業担当者を登録する（上長のみ）。

**エンドポイント**
```
POST /sales-persons
```

**リクエスト**
```json
{
  "name": "新人太郎",
  "email": "shinjin@example.com",
  "password": "initial123",
  "department": "営業1課",
  "manager_id": 3,
  "is_manager": false
}
```

| パラメータ | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| name | string | ○ | 氏名（最大50文字） |
| email | string | ○ | メールアドレス（重複不可） |
| password | string | ○ | 初期パスワード（8文字以上） |
| department | string | ○ | 部署 |
| manager_id | integer | - | 上長ID |
| is_manager | boolean | ○ | 上長フラグ |

**レスポンス（201 Created）**
```json
{
  "success": true,
  "data": {
    "sales_person_id": 26,
    "name": "新人太郎",
    "email": "shinjin@example.com",
    "created_at": "2026-01-12T10:00:00Z"
  }
}
```

---

### 9.3 営業詳細取得

営業担当者の詳細情報を取得する。

**エンドポイント**
```
GET /sales-persons/{id}
```

**レスポンス（200 OK）**
```json
{
  "success": true,
  "data": {
    "sales_person_id": 1,
    "name": "山田太郎",
    "email": "yamada@example.com",
    "department": "営業1課",
    "manager_id": 3,
    "manager_name": "田中一郎",
    "is_manager": false,
    "created_at": "2026-01-01T00:00:00Z",
    "updated_at": "2026-01-01T00:00:00Z"
  }
}
```

---

### 9.4 営業更新

営業担当者情報を更新する（上長のみ）。

**エンドポイント**
```
PUT /sales-persons/{id}
```

**リクエスト**
```json
{
  "name": "山田太郎",
  "email": "yamada@example.com",
  "department": "営業2課",
  "manager_id": 4,
  "is_manager": false
}
```

**レスポンス（200 OK）**
```json
{
  "success": true,
  "data": {
    "sales_person_id": 1,
    "updated_at": "2026-01-12T10:00:00Z"
  }
}
```

---

### 9.5 営業削除

営業担当者を削除する（上長のみ）。日報が存在する場合は削除不可。

**エンドポイント**
```
DELETE /sales-persons/{id}
```

**レスポンス（200 OK）**
```json
{
  "success": true,
  "data": {
    "message": "営業担当者を削除しました"
  }
}
```

---

## 10. 部署マスタ API（補助）

### 10.1 部署一覧取得

部署の一覧を取得する（プルダウン用）。

**エンドポイント**
```
GET /departments
```

**レスポンス（200 OK）**
```json
{
  "success": true,
  "data": {
    "departments": [
      "営業1課",
      "営業2課",
      "営業3課"
    ]
  }
}
```

---

## 付録A: ステータスコード一覧

| コード | 説明 | 用途 |
|--------|------|------|
| 200 | OK | 取得・更新・削除成功 |
| 201 | Created | 新規作成成功 |
| 400 | Bad Request | リクエスト形式不正 |
| 401 | Unauthorized | 認証エラー |
| 403 | Forbidden | 権限エラー |
| 404 | Not Found | リソースが存在しない |
| 409 | Conflict | 競合エラー |
| 422 | Unprocessable Entity | バリデーションエラー |
| 500 | Internal Server Error | サーバーエラー |

---

## 付録B: 日付・時刻フォーマット

| 種別 | フォーマット | 例 |
|------|-------------|-----|
| 日付 | YYYY-MM-DD | 2026-01-12 |
| 時刻 | HH:mm | 10:00 |
| 日時 | ISO 8601 | 2026-01-12T09:00:00Z |
