# Steering: GitHub Actions ワークフロー実装

作成日: 2026-02-14

## 目的・背景

### なぜこの作業が必要なのか

現在、test_on_k6の自動検証機能はローカル環境で動作していますが、CI/CDパイプラインに統合されていません。

- PRやpush時に自動的にテストが実行されない
- 手動でテストを実行する必要がある
- テスト失敗を見逃すリスクがある

### 解決しようとしている問題

1. **継続的インテグレーションの欠如**
   - コード変更時の自動テストがない
   - リグレッションの早期発見ができない

2. **品質保証の自動化**
   - PRレビュー時にテスト結果が見えない
   - mainブランチへのマージ前の品質チェックがない

3. **開発効率の低下**
   - ローカルでテストを実行し忘れる可能性
   - テスト環境の差異による問題

## ゴール

### 作業完了時に達成されるべき状態

1. **GitHub Actionsワークフロー**
   - `.github/workflows/test.yml` の作成
   - push/PR時に自動実行
   - MoonBitコンパイル + k6テスト + 自動検証

2. **効率的なCI実行**
   - 依存関係のキャッシュ
   - 並列実行（可能な部分）
   - 適切なタイムアウト設定

3. **明確なフィードバック**
   - テスト成功/失敗の明示
   - ログの可読性
   - 失敗時のエラーメッセージ

### 成功の基準

- [ ] `.github/workflows/test.yml` が作成されている
- [ ] push時にワークフローが自動実行される
- [ ] PR時にワークフローが自動実行される
- [ ] MoonBitコンパイルが成功する
- [ ] k6テストが実行される
- [ ] 自動検証が実行され、期待値と一致する
- [ ] テスト失敗時にワークフローが失敗する（exit code 1）
- [ ] ワークフロー実行時間が5分以内

## アプローチ

### 採用する技術的アプローチ

#### 1. ワークフロー構成

**.github/workflows/test.yml:**
```yaml
name: Test k6 MoonBit Library

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup MoonBit
        uses: moonbitlang/setup-moonbit@v1

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'
          cache-dependency-path: test_on_k6/package-lock.json

      - name: Install k6
        run: |
          sudo gpg -k
          sudo gpg --no-default-keyring --keyring /usr/share/keyrings/k6-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69
          echo "deb [signed-by=/usr/share/keyrings/k6-archive-keyring.gpg] https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list
          sudo apt-get update
          sudo apt-get install k6

      - name: Run tests with verification
        working-directory: test_on_k6
        run: npm run ci:verify
```

#### 2. セットアップステップ

1. **MoonBit環境**
   - `moonbitlang/setup-moonbit@v1` アクション使用
   - moonコマンドが使用可能になる

2. **Node.js環境**
   - `actions/setup-node@v4` アクション使用
   - Node.js 18をインストール
   - npm依存関係をキャッシュ

3. **k6インストール**
   - Grafana公式リポジトリから最新版をインストール
   - Ubuntu APTパッケージ使用

4. **テスト実行**
   - `npm run ci:verify` を実行
   - ビルド → テスト → 検証の全フロー

#### 3. 最適化

**キャッシュ戦略:**
- Node.js依存関係: `cache: 'npm'` で自動キャッシュ
- MoonBit依存関係: setup-moonbitアクションが自動処理

**並列化:**
- 現在は1つのジョブで完結（シンプル）
- 将来的には以下のような分割も可能:
  - Job 1: MoonBitコンパイルチェック
  - Job 2: test_on_k6実行

**タイムアウト:**
- デフォルト（360分）で十分
- 実際の実行時間は2-3分程度を想定

### 主要な実装方針

1. **シンプルさ優先**
   - 1つのジョブで全ステップ実行
   - 複雑な条件分岐を避ける
   - 明確なステップ名

2. **公式アクション使用**
   - `moonbitlang/setup-moonbit@v1`
   - `actions/setup-node@v4`
   - `actions/checkout@v4`

3. **環境の再現性**
   - ローカルと同じコマンド（`npm run ci:verify`）
   - 固定バージョンのNode.js（18）
   - 最新のk6

4. **エラーハンドリング**
   - 各ステップの失敗でワークフロー停止
   - 明確なエラーメッセージ

## スコープ

### 含むもの

1. **GitHub Actionsワークフロー**
   - `.github/workflows/test.yml`
   - push/PRトリガー
   - test_on_k6の実行

2. **セットアップ**
   - MoonBit環境
   - Node.js環境
   - k6インストール

3. **テスト実行**
   - npm run ci:verify
   - 結果の判定

4. **ドキュメント**
   - README.md更新（CI統合の説明）
   - 完了ドキュメント

### 含まないもの

1. **複雑な並列化**
   - 初期実装ではシンプルに1ジョブ
   - 必要になったら追加

2. **マトリックステスト**
   - 複数のNode.jsバージョン
   - 複数のOSバージョン
   - → 必要性が低い

3. **デプロイメント**
   - パッケージ公開
   - リリース作成
   - → 別タスク

4. **通知機能**
   - Slack通知
   - メール通知
   - → GitHub標準で十分

## 影響範囲

### 変更が影響するファイルやコンポーネント

**新規作成**
- `.github/workflows/test.yml` - ワークフロー定義
- `docs/completed/20260214_github_actions_workflow.md` - 完了ドキュメント

**変更**
- `test_on_k6/README.md` - CI統合の説明追加
- プロジェクトルートREADME.md（オプション）- バッジ追加

**変更なし**
- テストコード
- 検証スクリプト
- ビルド設定

### 他の機能への影響

**影響なし**
- ローカル開発環境
- 既存のビルドプロセス
- テスト内容

**相互作用**
- CIでtest_on_k6を実行
- テスト失敗時にPRマージをブロック（推奨設定）

## 実装手順（概要）

1. **ワークフロー作成**
   - `.github/workflows/test.yml` 作成
   - 基本構造の定義

2. **セットアップステップ追加**
   - MoonBit
   - Node.js
   - k6

3. **テスト実行ステップ追加**
   - npm run ci:verify

4. **動作確認**
   - ブランチにpushしてワークフロー実行
   - ログ確認
   - 成功/失敗の確認

5. **ドキュメント更新**
   - README.md
   - 完了ドキュメント

6. **PR作成**
   - ワークフローファイルをコミット
   - PRでCI動作を確認

## リスクと対策

### 想定されるリスク

1. **MoonBitセットアップの失敗**
   - 公式アクションが利用できない可能性
   - **対策**: 手動インストールスクリプトを準備

2. **k6インストールの失敗**
   - リポジトリの変更
   - **対策**: 公式ドキュメントの最新手順を確認

3. **ネットワーク依存のテスト失敗**
   - httpbin.orgへのアクセス失敗
   - **対策**: リトライロジック、または別のテストエンドポイント

4. **キャッシュの問題**
   - 古い依存関係がキャッシュされる
   - **対策**: キャッシュキーの適切な設定

5. **実行時間超過**
   - テストが遅すぎる
   - **対策**: タイムアウト設定、テストの最適化

## 参考資料

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [moonbitlang/setup-moonbit](https://github.com/moonbitlang/setup-moonbit)
- [k6 Installation](https://grafana.com/docs/k6/latest/set-up/install-k6/)
- [actions/setup-node](https://github.com/actions/setup-node)
