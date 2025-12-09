#!/bin/bash
# Katomo営業支援ツール - Railway PostgreSQLバックアップスクリプト
# 使用方法: ./scripts/backup-railway.sh [backup_name]
#
# 事前準備:
# 1. Railway CLIをインストール: npm install -g @railway/cli
# 2. Railway にログイン: railway login
# 3. プロジェクトをリンク: railway link

set -e

# 設定
BACKUP_DIR="./backups/railway"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_NAME="${1:-railway_backup_$TIMESTAMP}"

# バックアップディレクトリ作成
mkdir -p "$BACKUP_DIR"

echo "========================================"
echo "Railway PostgreSQL バックアップスクリプト"
echo "========================================"
echo "日時: $(date)"
echo "バックアップ名: $BACKUP_NAME"
echo ""

# Railway CLI確認
if ! command -v railway &> /dev/null; then
    echo "エラー: Railway CLIがインストールされていません"
    echo "インストール: npm install -g @railway/cli"
    exit 1
fi

# Railwayからデータベース接続情報を取得
echo "Railway接続情報を取得中..."
DATABASE_URL=$(railway variables --json 2>/dev/null | jq -r '.DATABASE_URL // empty')

if [ -z "$DATABASE_URL" ]; then
    echo "エラー: DATABASE_URLが見つかりません"
    echo "railway linkでプロジェクトをリンクしてください"
    exit 1
fi

echo "バックアップを実行中..."

# pg_dumpでバックアップ
pg_dump "$DATABASE_URL" > "$BACKUP_DIR/${BACKUP_NAME}.sql"

echo "[完了] SQLバックアップ: $BACKUP_DIR/${BACKUP_NAME}.sql"

# 圧縮版も作成
gzip -c "$BACKUP_DIR/${BACKUP_NAME}.sql" > "$BACKUP_DIR/${BACKUP_NAME}.sql.gz"
echo "[完了] 圧縮バックアップ: $BACKUP_DIR/${BACKUP_NAME}.sql.gz"

# バックアップ情報を記録
echo "{
  \"name\": \"$BACKUP_NAME\",
  \"timestamp\": \"$(date -Iseconds)\",
  \"source\": \"railway\",
  \"size\": \"$(du -h "$BACKUP_DIR/${BACKUP_NAME}.sql" | cut -f1)\",
  \"compressed_size\": \"$(du -h "$BACKUP_DIR/${BACKUP_NAME}.sql.gz" | cut -f1)\"
}" > "$BACKUP_DIR/${BACKUP_NAME}.json"

echo ""
echo "========================================"
echo "Railway バックアップ完了"
echo "========================================"
echo "ファイル一覧:"
ls -lh "$BACKUP_DIR/${BACKUP_NAME}"*
echo ""
echo "復元コマンド:"
echo "  ./scripts/restore-railway.sh $BACKUP_NAME"
echo "========================================"
