#!/bin/bash

# データベースバックアップスクリプト
# 使用方法: ./scripts/backup-db.sh

# PostgreSQLのパスを設定（Homebrewでインストールした場合）
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"

# 設定
DB_NAME="katomo_db"
DB_USER="katomo"
BACKUP_DIR="./backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="${BACKUP_DIR}/katomo_db_${TIMESTAMP}.sql"

# バックアップディレクトリを作成
mkdir -p $BACKUP_DIR

echo "📦 データベースバックアップを開始します..."
echo "データベース: $DB_NAME"
echo "保存先: $BACKUP_FILE"

# PostgreSQLのバックアップを実行
pg_dump -U $DB_USER -h localhost -p 5432 $DB_NAME > $BACKUP_FILE

if [ $? -eq 0 ]; then
    echo "✅ バックアップが完了しました: $BACKUP_FILE"

    # バックアップファイルのサイズを表示
    SIZE=$(ls -lh $BACKUP_FILE | awk '{print $5}')
    echo "📊 ファイルサイズ: $SIZE"

    # 古いバックアップを削除（30日以前のもの）
    echo "🧹 古いバックアップファイルを削除します..."
    find $BACKUP_DIR -name "katomo_db_*.sql" -mtime +30 -delete

    # 残っているバックアップファイル数を表示
    COUNT=$(ls -1 $BACKUP_DIR/katomo_db_*.sql 2>/dev/null | wc -l)
    echo "📁 保存されているバックアップ数: $COUNT"
else
    echo "❌ バックアップに失敗しました"
    exit 1
fi
