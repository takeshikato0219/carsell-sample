# Katomo 営業支援ツール - セットアップガイド

## 前提条件

以下のツールがインストールされている必要があります:

- Node.js 18以上
- npm または pnpm
- Docker & Docker Compose
- Git

## セットアップ手順

### 1. リポジトリのクローン

```bash
git clone <repository-url>
cd katomo営業支援ツール
```

### 2. データベースとRedisの起動

```bash
docker-compose up -d
```

起動確認:
```bash
docker-compose ps
```

すべてのコンテナが`Up`状態になっていることを確認してください。

### 3. データベースの初期化

PostgreSQLコンテナに接続:
```bash
docker exec -it katomo_postgres psql -U katomo -d katomo_db
```

スキーマを適用:
```sql
\i /docker-entrypoint-initdb.d/init.sql
```

別の方法として、ホストから実行:
```bash
docker exec -i katomo_postgres psql -U katomo -d katomo_db < database/schema.sql
```

シードデータを挿入:
```bash
docker exec -i katomo_postgres psql -U katomo -d katomo_db < database/seeds.sql
```

### 4. バックエンドのセットアップ

```bash
cd backend

# 依存関係のインストール
npm install

# 環境変数の設定
cp .env.example .env

# .envファイルを編集して、必要な値を設定
```

### 5. フロントエンドのセットアップ

```bash
cd frontend

# 依存関係のインストール
npm install

# 環境変数の設定
cp .env.example .env.local

# .env.localファイルを編集して、必要な値を設定
```

### 6. 開発サーバーの起動

**バックエンド:**
```bash
cd backend
npm run start:dev
```

バックエンドは `http://localhost:4000` で起動します。

**フロントエンド:**
```bash
cd frontend
npm run dev
```

フロントエンドは `http://localhost:3000` で起動します。

### 7. 動作確認

1. ブラウザで `http://localhost:3000` にアクセス
2. API の動作確認: `http://localhost:4000/api` にアクセス

## データベース管理

### マイグレーション

新しいマイグレーションの生成:
```bash
cd backend
npm run migration:generate -- -n MigrationName
```

マイグレーションの実行:
```bash
npm run migration:run
```

マイグレーションの取り消し:
```bash
npm run migration:revert
```

### シードデータの再投入

```bash
docker exec -i katomo_postgres psql -U katomo -d katomo_db < database/seeds.sql
```

## トラブルシューティング

### ポートが既に使用されている

```bash
# 使用中のポートを確認
lsof -i :4000  # バックエンド
lsof -i :3000  # フロントエンド
lsof -i :5432  # PostgreSQL
lsof -i :6379  # Redis

# プロセスを終了
kill -9 <PID>
```

### Dockerコンテナの再起動

```bash
docker-compose down
docker-compose up -d
```

### データベースのリセット

```bash
docker-compose down -v  # ボリュームも削除
docker-compose up -d
# スキーマとシードを再度適用
```

### ログの確認

```bash
# すべてのコンテナのログ
docker-compose logs

# 特定のコンテナのログ
docker-compose logs postgres
docker-compose logs redis
docker-compose logs minio

# リアルタイムでログを表示
docker-compose logs -f
```

## 本番環境へのデプロイ

本番環境へのデプロイについては、別途ドキュメントを参照してください。

## サポート

問題が発生した場合は、開発チームまでお問い合わせください。
