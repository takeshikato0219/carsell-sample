#!/bin/bash
# Katomo営業支援ツール - PostgreSQLバックアップスクリプト
# 使用方法: ./scripts/backup.sh [backup_name]

set -e

# 設定
BACKUP_DIR="./backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_NAME="${1:-backup_$TIMESTAMP}"
CONTAINER_NAME="katomo-postgres"

# Docker環境の場合のDB接続情報
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-4432}"
DB_NAME="${DB_NAME:-katomo_db}"
DB_USER="${DB_USER:-katomo}"
DB_PASSWORD="${DB_PASSWORD:-katomo_dev_password}"

# バックアップディレクトリ作成
mkdir -p "$BACKUP_DIR"

echo "========================================"
echo "Katomo バックアップスクリプト"
echo "========================================"
echo "日時: $(date)"
echo "バックアップ名: $BACKUP_NAME"
echo ""

# Dockerコンテナが起動しているか確認
if docker ps --format '{{.Names}}' | grep -q "$CONTAINER_NAME"; then
    echo "[Docker] PostgreSQLコンテナからバックアップ中..."

    # pg_dumpでバックアップ（Docker内で実行）
    docker exec "$CONTAINER_NAME" pg_dump -U "$DB_USER" "$DB_NAME" > "$BACKUP_DIR/${BACKUP_NAME}.sql"

    echo "[完了] SQLバックアップ: $BACKUP_DIR/${BACKUP_NAME}.sql"

    # 圧縮版も作成
    gzip -c "$BACKUP_DIR/${BACKUP_NAME}.sql" > "$BACKUP_DIR/${BACKUP_NAME}.sql.gz"
    echo "[完了] 圧縮バックアップ: $BACKUP_DIR/${BACKUP_NAME}.sql.gz"

else
    echo "[ローカル] pg_dumpでバックアップ中..."

    # ローカルのpg_dumpを使用
    PGPASSWORD="$DB_PASSWORD" pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" "$DB_NAME" > "$BACKUP_DIR/${BACKUP_NAME}.sql"

    echo "[完了] SQLバックアップ: $BACKUP_DIR/${BACKUP_NAME}.sql"

    # 圧縮版も作成
    gzip -c "$BACKUP_DIR/${BACKUP_NAME}.sql" > "$BACKUP_DIR/${BACKUP_NAME}.sql.gz"
    echo "[完了] 圧縮バックアップ: $BACKUP_DIR/${BACKUP_NAME}.sql.gz"
fi

# バックアップ情報を記録
echo "{
  \"name\": \"$BACKUP_NAME\",
  \"timestamp\": \"$(date -Iseconds)\",
  \"database\": \"$DB_NAME\",
  \"size\": \"$(du -h "$BACKUP_DIR/${BACKUP_NAME}.sql" | cut -f1)\",
  \"compressed_size\": \"$(du -h "$BACKUP_DIR/${BACKUP_NAME}.sql.gz" | cut -f1)\"
}" > "$BACKUP_DIR/${BACKUP_NAME}.json"

echo ""
echo "========================================"
echo "バックアップ完了"
echo "========================================"
echo "ファイル一覧:"
ls -lh "$BACKUP_DIR/${BACKUP_NAME}"*
echo ""
echo "復元コマンド:"
echo "  ./scripts/restore.sh $BACKUP_NAME"
echo "========================================"
