#!/bin/bash
# Katomo営業支援ツール - Railway PostgreSQL復元スクリプト
# 使用方法: ./scripts/restore-railway.sh <backup_name>
#
# 事前準備:
# 1. Railway CLIをインストール: npm install -g @railway/cli
# 2. Railway にログイン: railway login
# 3. プロジェクトをリンク: railway link

set -e

# 設定
BACKUP_DIR="./backups/railway"
BACKUP_NAME="$1"

echo "========================================"
echo "Railway PostgreSQL 復元スクリプト"
echo "========================================"
echo "日時: $(date)"
echo ""

# 引数チェック
if [ -z "$BACKUP_NAME" ]; then
    echo "使用方法: ./scripts/restore-railway.sh <backup_name>"
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

echo ""
echo "========================================"
echo "警告: この操作は本番データベースを上書きします！"
echo "========================================"
echo ""
read -p "本当に続行しますか？ (yes-i-am-sure と入力): " CONFIRM

if [ "$CONFIRM" != "yes-i-am-sure" ]; then
    echo "復元をキャンセルしました。"
    exit 0
fi

echo ""
echo "復元を開始します..."

# psqlで復元
psql "$DATABASE_URL" < "$BACKUP_FILE"

echo ""
echo "========================================"
echo "Railway 復元完了"
echo "========================================"
echo "復元元: $BACKUP_FILE"
echo "========================================"
