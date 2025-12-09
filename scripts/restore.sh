#!/bin/bash
# Katomo営業支援ツール - PostgreSQL復元スクリプト
# 使用方法: ./scripts/restore.sh <backup_name>

set -e

# 設定
BACKUP_DIR="./backups"
BACKUP_NAME="$1"
CONTAINER_NAME="katomo-postgres"

# Docker環境の場合のDB接続情報
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-4432}"
DB_NAME="${DB_NAME:-katomo_db}"
DB_USER="${DB_USER:-katomo}"
DB_PASSWORD="${DB_PASSWORD:-katomo_dev_password}"

echo "========================================"
echo "Katomo 復元スクリプト"
echo "========================================"
echo "日時: $(date)"
echo ""

# 引数チェック
if [ -z "$BACKUP_NAME" ]; then
    echo "使用方法: ./scripts/restore.sh <backup_name>"
    echo ""
    echo "利用可能なバックアップ:"
    ls -1 "$BACKUP_DIR"/*.sql 2>/dev/null | xargs -I {} basename {} .sql || echo "  (バックアップが見つかりません)"
    exit 1
fi

# バックアップファイルの存在確認
BACKUP_FILE="$BACKUP_DIR/${BACKUP_NAME}.sql"
BACKUP_FILE_GZ="$BACKUP_DIR/${BACKUP_NAME}.sql.gz"

if [ -f "$BACKUP_FILE" ]; then
    echo "バックアップファイル: $BACKUP_FILE"
elif [ -f "$BACKUP_FILE_GZ" ]; then
    echo "圧縮ファイルを解凍中..."
    gunzip -k "$BACKUP_FILE_GZ"
    echo "バックアップファイル: $BACKUP_FILE"
else
    echo "エラー: バックアップファイルが見つかりません"
    echo "  $BACKUP_FILE"
    echo "  $BACKUP_FILE_GZ"
    exit 1
fi

echo ""
echo "警告: この操作は現在のデータベースを上書きします！"
read -p "続行しますか？ (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "復元をキャンセルしました。"
    exit 0
fi

echo ""
echo "復元を開始します..."

# Dockerコンテナが起動しているか確認
if docker ps --format '{{.Names}}' | grep -q "$CONTAINER_NAME"; then
    echo "[Docker] PostgreSQLコンテナに復元中..."

    # 既存の接続を切断してDBを再作成
    docker exec "$CONTAINER_NAME" psql -U "$DB_USER" -d postgres -c "
        SELECT pg_terminate_backend(pg_stat_activity.pid)
        FROM pg_stat_activity
        WHERE pg_stat_activity.datname = '$DB_NAME'
        AND pid <> pg_backend_pid();
    " 2>/dev/null || true

    docker exec "$CONTAINER_NAME" psql -U "$DB_USER" -d postgres -c "DROP DATABASE IF EXISTS $DB_NAME;"
    docker exec "$CONTAINER_NAME" psql -U "$DB_USER" -d postgres -c "CREATE DATABASE $DB_NAME OWNER $DB_USER;"

    # バックアップを復元
    cat "$BACKUP_FILE" | docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" "$DB_NAME"

else
    echo "[ローカル] psqlで復元中..."

    # 既存の接続を切断してDBを再作成
    PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres -c "
        SELECT pg_terminate_backend(pg_stat_activity.pid)
        FROM pg_stat_activity
        WHERE pg_stat_activity.datname = '$DB_NAME'
        AND pid <> pg_backend_pid();
    " 2>/dev/null || true

    PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres -c "DROP DATABASE IF EXISTS $DB_NAME;"
    PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres -c "CREATE DATABASE $DB_NAME OWNER $DB_USER;"

    # バックアップを復元
    PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" "$DB_NAME" < "$BACKUP_FILE"
fi

echo ""
echo "========================================"
echo "復元完了"
echo "========================================"
echo "復元元: $BACKUP_FILE"
echo "データベース: $DB_NAME"
echo "========================================"
