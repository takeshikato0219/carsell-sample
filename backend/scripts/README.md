# データベースバックアップ・リストアガイド

## 概要

このディレクトリには、katomotorデータベースのバックアップとリストアを行うスクリプトがあります。

## バックアップ

### 手動バックアップ

```bash
cd backend
./scripts/backup-db.sh
```

バックアップファイルは `backend/backups/` ディレクトリに保存されます。
ファイル名形式: `katomo_db_YYYYMMDD_HHMMSS.sql`

### 自動バックアップ（推奨）

cronで定期的にバックアップを実行することをお勧めします。

```bash
# crontabを編集
crontab -e

# 毎日午前3時にバックアップを実行
0 3 * * * cd /Users/takeshi/Desktop/katomo営業支援ツール/backend && ./scripts/backup-db.sh >> ./logs/backup.log 2>&1
```

### バックアップの保存期間

- 古いバックアップファイルは30日後に自動削除されます
- 重要なバックアップは別の場所にコピーして保存することをお勧めします

## リストア

### 利用可能なバックアップを確認

```bash
cd backend
./scripts/restore-db.sh
```

引数なしで実行すると、利用可能なバックアップファイルの一覧が表示されます。

### データベースをリストア

```bash
cd backend
./scripts/restore-db.sh ./backups/katomo_db_20251209_120000.sql
```

**⚠️ 警告**: リストアを実行すると、既存のデータベースは完全に上書きされます。

確認プロンプトで `yes` と入力すると実行されます。

## 緊急時の対応

### ユーザーデータが消えた場合

1. 最新のバックアップファイルを確認
```bash
cd backend
ls -lth backups/
```

2. リストアを実行
```bash
./scripts/restore-db.sh ./backups/katomo_db_YYYYMMDD_HHMMSS.sql
```

3. アプリケーションを再起動
```bash
# バックエンドを再起動
PORT=4000 npm run start:dev
```

### ユーザー管理で問題が発生した場合

バックアップからリストアする以外に、以下の方法もあります:

#### 方法1: デフォルトユーザーを再作成

データベースをクリアしてアプリケーションを再起動すると、デフォルトユーザーが自動作成されます:

```bash
# データベースをクリア
dropdb -U katomo katomo_db
createdb -U katomo katomo_db

# バックエンドを再起動（自動的にデフォルトユーザーが作成される）
PORT=4000 npm run start:dev
```

デフォルトアカウント:
- admin@katomo.com / admin123 (管理者)
- manager@katomo.com / manager123 (マネージャー)
- sales@katomo.com / sales123 (営業)

#### 方法2: SQLで直接修正

PostgreSQLに接続して直接データを修正:

```bash
psql -U katomo katomo_db

-- ユーザー一覧を確認
SELECT id, email, name, role, "isActive" FROM users;

-- 特定ユーザーをアクティブに戻す
UPDATE users SET "isActive" = true WHERE email = 'example@katomo.com';

-- ユーザーのロールを変更
UPDATE users SET role = 'admin' WHERE email = 'example@katomo.com';

-- パスワードをリセット（bcryptハッシュ: "password123"）
UPDATE users SET "passwordHash" = '$2a$10$YourHashHere' WHERE email = 'example@katomo.com';
```

## ベストプラクティス

1. **定期的なバックアップ**: cronで毎日自動バックアップを設定
2. **重要なバックアップの外部保存**: クラウドストレージや外付けHDDにコピー
3. **リストア前のテスト**: 本番環境でリストアする前に、テスト環境で確認
4. **バックアップの確認**: 定期的にバックアップファイルが正常に作成されているか確認

## トラブルシューティング

### "Permission denied" エラー

スクリプトに実行権限がない場合:
```bash
chmod +x scripts/*.sh
```

### "pg_dump: command not found" エラー

PostgreSQLのツールがPATHに含まれていない場合:
```bash
# Homebrewでインストールした場合
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
```

### バックアップファイルが大きすぎる場合

圧縮バックアップを作成:
```bash
pg_dump -U katomo katomo_db | gzip > backups/katomo_db_$(date +%Y%m%d_%H%M%S).sql.gz
```

リストア時は解凍してから:
```bash
gunzip -c backups/katomo_db_20251209_120000.sql.gz | psql -U katomo katomo_db
```

## サポート

問題が発生した場合は、バックアップログを確認してください:
```bash
cat logs/backup.log
```
