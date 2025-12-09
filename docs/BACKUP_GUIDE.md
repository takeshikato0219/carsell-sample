# Katomo営業支援ツール - バックアップ・復元ガイド

## 概要

このドキュメントでは、Katomo営業支援ツールのデータバックアップと復元方法について説明します。

データは2種類の場所に保存されています：
1. **ブラウザ（localStorage）** - フロントエンドの設定・契約データ等
2. **PostgreSQL（データベース）** - 顧客・見積・ユーザー情報等

---

## 1. ブラウザデータのバックアップ（localStorage）

### 対象データ
- 営業目標・契約データ
- サイドバー順序設定
- アプリ設定
- 見積データ
- 顧客データ（ローカル）
- 契約管理データ

### バックアップ方法

#### 方法1: 設定画面から（推奨）
1. ダッシュボード → 設定 を開く
2. 「データバックアップ・復元」セクションを見つける
3. 「バックアップをダウンロード」ボタンをクリック
4. JSONファイルが自動でダウンロードされる

#### 方法2: ブラウザのコンソールから
```javascript
// コンソールで実行
JSON.stringify(Object.keys(localStorage).reduce((acc, key) => {
  acc[key] = JSON.parse(localStorage.getItem(key));
  return acc;
}, {}), null, 2);
```

### 復元方法
1. ダッシュボード → 設定 を開く
2. 「バックアップから復元」ボタンをクリック
3. バックアップJSONファイルを選択
4. 確認ダイアログでOKをクリック
5. ページが自動で再読み込みされる

---

## 2. PostgreSQLデータベースのバックアップ

### ローカル開発環境

#### バックアップ
```bash
# プロジェクトルートで実行
./scripts/backup.sh

# 名前を指定する場合
./scripts/backup.sh my_backup_20240101
```

バックアップファイルは `./backups/` ディレクトリに保存されます。

#### 復元
```bash
# プロジェクトルートで実行
./scripts/restore.sh backup_20240101_120000

# 利用可能なバックアップを確認
./scripts/list-backups.sh
```

### Railway本番環境

#### 事前準備
```bash
# Railway CLIをインストール
npm install -g @railway/cli

# Railwayにログイン
railway login

# プロジェクトをリンク
cd /path/to/katomo営業支援ツール
railway link
```

#### バックアップ
```bash
# プロジェクトルートで実行
./scripts/backup-railway.sh

# 名前を指定する場合
./scripts/backup-railway.sh production_backup_20240101
```

バックアップファイルは `./backups/railway/` ディレクトリに保存されます。

#### 復元
```bash
# 警告: 本番データを上書きします！
./scripts/restore-railway.sh railway_backup_20240101_120000
```

---

## 3. バックアップスケジュール推奨

| 頻度 | 対象 | 方法 |
|------|------|------|
| 毎日 | Railway PostgreSQL | `./scripts/backup-railway.sh` |
| 週1回 | ブラウザデータ | 設定画面からダウンロード |
| 月1回 | 全データ | 両方をまとめて保存 |

### 自動バックアップ（cron設定例）

```bash
# crontab -e で以下を追加
# 毎日午前3時にRailwayバックアップ
0 3 * * * cd /path/to/katomo営業支援ツール && ./scripts/backup-railway.sh daily_$(date +\%Y\%m\%d)

# 週1回（日曜深夜）にローカルバックアップ
0 4 * * 0 cd /path/to/katomo営業支援ツール && ./scripts/backup.sh weekly_$(date +\%Y\%m\%d)
```

---

## 4. 障害時の復旧手順

### ケース1: ブラウザデータが消えた
1. 最新のJSONバックアップファイルを用意
2. 設定画面から復元

### ケース2: データベースが破損した
1. 最新のSQLバックアップファイルを用意
2. `./scripts/restore.sh` または `./scripts/restore-railway.sh` で復元

### ケース3: 完全復旧（新環境構築）
1. リポジトリをクローン
2. Docker環境を起動 `docker-compose up -d`
3. データベースを復元 `./scripts/restore.sh <backup_name>`
4. フロントエンドを起動
5. ブラウザでログイン後、設定画面からJSONを復元

---

## 5. Railway固有の設定

### Railwayダッシュボードでの自動バックアップ

Railwayは標準でPostgreSQLの自動バックアップ機能を提供しています：

1. [Railway Dashboard](https://railway.app/dashboard) にログイン
2. プロジェクトを選択
3. PostgreSQLサービスをクリック
4. 「Settings」タブを開く
5. 「Backups」セクションで自動バックアップを確認

### 環境変数の確認

```bash
# 現在の環境変数を確認
railway variables

# DATABASE_URLが設定されていることを確認
railway variables --json | jq '.DATABASE_URL'
```

---

## 6. トラブルシューティング

### バックアップスクリプトが動かない
```bash
# 実行権限を付与
chmod +x scripts/*.sh

# Dockerが起動しているか確認
docker ps | grep katomo-postgres
```

### Railway接続エラー
```bash
# ログイン状態を確認
railway whoami

# プロジェクトのリンク状態を確認
railway status
```

### ファイルサイズが大きすぎる
```bash
# 圧縮版を使用（.sql.gz）
ls -lh backups/*.sql.gz

# 古いバックアップを削除
find backups/ -name "*.sql" -mtime +30 -delete
```

---

## 7. ファイル構成

```
katomo営業支援ツール/
├── scripts/
│   ├── backup.sh           # ローカルDBバックアップ
│   ├── restore.sh          # ローカルDB復元
│   ├── backup-railway.sh   # Railway DBバックアップ
│   ├── restore-railway.sh  # Railway DB復元
│   └── list-backups.sh     # バックアップ一覧表示
├── backups/
│   ├── *.sql               # ローカルバックアップ
│   ├── *.sql.gz            # 圧縮版
│   └── railway/            # Railwayバックアップ
└── docs/
    └── BACKUP_GUIDE.md     # このドキュメント
```

---

## 問い合わせ

バックアップ・復元で問題が発生した場合は、システム管理者に連絡してください。
