#!/bin/bash
# Katomo営業支援ツール - バックアップ一覧表示スクリプト
# 使用方法: ./scripts/list-backups.sh

BACKUP_DIR="./backups"
RAILWAY_BACKUP_DIR="./backups/railway"

echo "========================================"
echo "Katomo バックアップ一覧"
echo "========================================"
echo ""

echo "【ローカル開発環境バックアップ】"
echo "ディレクトリ: $BACKUP_DIR"
echo "----------------------------------------"
if [ -d "$BACKUP_DIR" ] && ls "$BACKUP_DIR"/*.sql 1> /dev/null 2>&1; then
    printf "%-30s %-12s %-20s\n" "名前" "サイズ" "作成日時"
    echo "----------------------------------------"
    for f in "$BACKUP_DIR"/*.sql; do
        name=$(basename "$f" .sql)
        size=$(du -h "$f" | cut -f1)
        date=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$f" 2>/dev/null || stat -c "%y" "$f" 2>/dev/null | cut -d' ' -f1,2 | cut -d'.' -f1)
        printf "%-30s %-12s %-20s\n" "$name" "$size" "$date"
    done
else
    echo "  (バックアップがありません)"
fi

echo ""
echo "【Railway本番環境バックアップ】"
echo "ディレクトリ: $RAILWAY_BACKUP_DIR"
echo "----------------------------------------"
if [ -d "$RAILWAY_BACKUP_DIR" ] && ls "$RAILWAY_BACKUP_DIR"/*.sql 1> /dev/null 2>&1; then
    printf "%-30s %-12s %-20s\n" "名前" "サイズ" "作成日時"
    echo "----------------------------------------"
    for f in "$RAILWAY_BACKUP_DIR"/*.sql; do
        name=$(basename "$f" .sql)
        size=$(du -h "$f" | cut -f1)
        date=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$f" 2>/dev/null || stat -c "%y" "$f" 2>/dev/null | cut -d' ' -f1,2 | cut -d'.' -f1)
        printf "%-30s %-12s %-20s\n" "$name" "$size" "$date"
    done
else
    echo "  (バックアップがありません)"
fi

echo ""
echo "========================================"
echo "コマンド一覧:"
echo "  ./scripts/backup.sh [名前]          - ローカルDBバックアップ"
echo "  ./scripts/restore.sh <名前>         - ローカルDB復元"
echo "  ./scripts/backup-railway.sh [名前]  - Railway DBバックアップ"
echo "  ./scripts/restore-railway.sh <名前> - Railway DB復元"
echo "========================================"
