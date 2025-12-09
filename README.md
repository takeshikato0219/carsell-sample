# Katomo 営業支援ツール

自動車販売営業を効率化するための統合管理システム

## プロジェクト概要

紙ベースの顧客情報をデジタル化し、営業活動全体を一元管理する営業支援ツールです。
OCRによる自動読み取り、AIによるメール文面生成、カンバン方式の進捗管理など、最新技術を活用して営業効率を大幅に向上させます。

## 主要機能

### 1. 顧客管理
- アンケート・電話メモのスキャン & OCR自動読み取り
- 顧客情報の一元管理
- 見積もり管理（Excelアップロード対応）
- 商談履歴・音声メモ・テキストメモの保存
- 定期連絡スケジュール管理

### 2. AI支援機能
- 過去の商談内容を基にしたメール文面の自動生成
- パーソナライズされた顧客対応支援
- 音声メモの文字起こし（将来実装）

### 3. 営業進捗管理（カンバンボード）
- ドラッグ&ドロップで直感的な進捗管理
- 8つのステージで案件を可視化
  - 初回接触 → ヒアリング → 見積もり提示 → 商談中 → 契約 → 納車待ち → 納車済み / 失注
- Notion風のリッチテキストメモ機能

### 4. 営業目標管理
- 個人・チーム目標の設定と追跡
- 契約台数・売上・利益率のリアルタイム集計
- ダッシュボードでの可視化
- Excelからの契約・原価情報取り込み

### 5. バックオーダー管理
- 納車待ち案件の一覧管理
- 納車予定日の追跡
- 遅延アラート機能

### 6. 納車前後の顧客フォロー
- 納車前の定期連絡サポート
- 納車後のアフターフォロー管理

## 技術スタック

### フロントエンド
- Next.js 14 (App Router)
- TypeScript
- Tailwind CSS + shadcn/ui
- Zustand (状態管理)
- @dnd-kit (カンバン機能)
- Tiptap (リッチテキストエディタ)

### バックエンド
- NestJS
- TypeScript
- PostgreSQL
- Redis
- TypeORM / Prisma

### AI・外部サービス
- OpenAI GPT-4 / Anthropic Claude (メール生成)
- Tesseract OCR / Google Cloud Vision (OCR)
- SendGrid / Resend (メール送信)
- AWS S3 / Cloudflare R2 (ファイルストレージ)

## ドキュメント

- [基本設計書](./基本設計書.md) - システム全体の設計方針
- [プロジェクト構成](./プロジェクト構成.md) - ディレクトリ構造と技術仕様
- [データベース設計](./データベース設計.md) - テーブル定義とER図

## 開発フェーズ

### Phase 1: MVP（基本機能）
- [ ] ユーザー認証・権限管理
- [ ] 顧客管理基本機能
- [ ] 簡易カンバンボード
- [ ] 基本的な目標管理ダッシュボード

### Phase 2: コア機能
- [ ] OCRスキャン機能
- [ ] 見積もり管理
- [ ] メモ機能強化（Notion風エディタ）
- [ ] 連絡履歴管理

### Phase 3: AI・自動化
- [ ] AIメール生成機能
- [ ] 自動リマインダー
- [ ] 音声メモ文字起こし

### Phase 4: 高度な機能
- [ ] 詳細な分析・レポート
- [ ] モバイル対応
- [ ] 外部システム連携

## セットアップ（開発環境）

### 前提条件
- Node.js 18+
- Docker & Docker Compose
- Git

### 手順

1. リポジトリのクローン
```bash
git clone <repository-url>
cd katomo営業支援ツール
```

2. データベースの起動
```bash
docker-compose up -d postgres redis
```

3. フロントエンドのセットアップ
```bash
cd frontend
pnpm install
cp .env.example .env.local
pnpm dev
```

4. バックエンドのセットアップ
```bash
cd backend
pnpm install
cp .env.example .env
pnpm migration:run
pnpm start:dev
```

5. ブラウザでアクセス
- フロントエンド: http://localhost:3000
- バックエンドAPI: http://localhost:4000

## 環境変数

### Frontend (.env.local)
```
NEXT_PUBLIC_API_URL=http://localhost:4000
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

### Backend (.env)
```
DATABASE_URL=postgresql://user:password@localhost:5432/katomo
REDIS_URL=redis://localhost:6379
JWT_SECRET=your-secret-key
OPENAI_API_KEY=sk-...
```

詳細は [プロジェクト構成](./プロジェクト構成.md) を参照してください。

## ライセンス

社内専用ツールのため、ライセンスは未定

## サポート

問題が発生した場合は、開発チームまでお問い合わせください。

## 貢献

開発チームメンバーのみが貢献できます。

---

**バージョン**: 1.0.0
**最終更新日**: 2025-11-30
