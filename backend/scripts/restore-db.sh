#!/bin/bash

# データベースリストアスクリプト
# 使用方法: ./scripts/restore-db.sh [バックアップファイル]

# PostgreSQLのパスを設定（Homebrewでインストールした場合）
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"

# 設定
DB_NAME="katomo_db"
DB_USER="katomo"
BACKUP_DIR="./backups"

# 引数チェック
if [ $# -eq 0 ]; then
    echo "📋 利用可能なバックアップファイル:"
    ls -lth $BACKUP_DIR/katomo_db_*.sql 2>/dev/null | head -10

    echo ""
    echo "使用方法: ./scripts/restore-db.sh [バックアップファイルパス]"
    echo "例: ./scripts/restore-db.sh ./backups/katomo_db_20251209_120000.sql"
    exit 1
fi

BACKUP_FILE=$1

# ファイルの存在確認
if [ ! -f "$BACKUP_FILE" ]; then
    echo "❌ バックアップファイルが見つかりません: $BACKUP_FILE"
    exit 1
fi

echo "⚠️  警告: このスクリプトは既存のデータベースを上書きします"
echo "データベース: $DB_NAME"
echo "バックアップファイル: $BACKUP_FILE"
echo ""
read -p "続行しますか? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "❌ リストアをキャンセルしました"
    exit 0
fi

echo "🔄 データベースをリストアします..."

# 既存のデータベースを削除して再作成
echo "📦 既存のデータベースを削除..."
dropdb -U $DB_USER -h localhost -p 5432 $DB_NAME 2>/dev/null

echo "🆕 新しいデータベースを作成..."
createdb -U $DB_USER -h localhost -p 5432 $DB_NAME

# バックアップからリストア
echo "📥 バックアップからデータをリストア..."
psql -U $DB_USER -h localhost -p 5432 $DB_NAME < $BACKUP_FILE

if [ $? -eq 0 ]; then
    echo "✅ リストアが完了しました"
else
    echo "❌ リストアに失敗しました"
    exit 1
fi
