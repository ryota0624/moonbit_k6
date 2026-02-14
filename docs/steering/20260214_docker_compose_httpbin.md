# Steering: Docker Compose httpbin環境構築

作成日: 2026-02-14

## 目的・背景

### なぜこの作業が必要なのか

現在、test_on_k6は外部サービス（https://httpbin.org）に依存しています。

**問題点:**
- ネットワークに依存したテスト（httpbin.orgがダウンすると失敗）
- CI環境でのネットワークレイテンシ
- テストの独立性が低い
- レート制限の可能性

### 解決しようとしている問題

1. **外部依存の排除**
   - httpbin.orgへの依存を削除
   - ローカル環境で完結するテスト

2. **テストの安定性向上**
   - ネットワークエラーによる偽陽性を防ぐ
   - 予測可能なレスポンス

3. **CI/CD環境での高速化**
   - ローカルネットワーク通信（レイテンシ削減）
   - キャッシュによる起動時間短縮

## ゴール

### 作業完了時に達成されるべき状態

1. **Docker Compose環境**
   - `test_on_k6/docker-compose.yml` の作成
   - httpbinコンテナの定義
   - ヘルスチェック設定

2. **テストコードの対応**
   - 環境変数でベースURLを切り替え
   - デフォルトはローカル（http://localhost:8080）
   - CI環境での設定

3. **npm スクリプト更新**
   - Docker Compose起動・停止
   - テスト実行フロー統合

4. **GitHub Actions統合**
   - ワークフローでDocker Composeを使用
   - サービスコンテナとして起動

### 成功の基準

- [ ] `docker-compose.yml` が作成されている
- [ ] `docker compose up -d` でhttpbinが起動する
- [ ] テストがローカルhttpbinに対して実行される
- [ ] 既存のテストがすべてパスする
- [ ] GitHub Actionsでテストが成功する
- [ ] 外部ネットワークへの依存がない

## アプローチ

### 採用する技術的アプローチ

#### 1. Docker Compose構成

**test_on_k6/docker-compose.yml:**
```yaml
version: '3.8'

services:
  httpbin:
    image: kennethreitz/httpbin:latest
    ports:
      - "8080:80"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/status/200"]
      interval: 5s
      timeout: 3s
      retries: 3
      start_period: 5s
```

#### 2. テストコードの修正

**setup()関数の修正:**
```moonbit
pub fn setup() -> @core.Any {
  // 環境変数から取得、デフォルトはローカル
  let base_url = match @k6.get_env("HTTPBIN_URL") {
    "" => "http://localhost:8080"
    url => url
  }

  let config = @k6.TestSetup::new()
    .base_url(base_url)
    .timeout("10s")
    .build()

  config
}
```

#### 3. npm スクリプト拡張

**package.json:**
```json
{
  "scripts": {
    "docker:up": "docker compose up -d && sleep 5",
    "docker:down": "docker compose down",
    "docker:logs": "docker compose logs -f httpbin",
    "test:local": "npm run docker:up && npm run test && npm run docker:down",
    "test:json:local": "npm run docker:up && npm run test:json && npm run docker:down",
    "ci:verify:local": "npm run build && npm run build:verify && npm run test:json:local && npm run verify"
  }
}
```

#### 4. GitHub Actions修正

**ワークフロー修正案:**
```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    services:
      httpbin:
        image: kennethreitz/httpbin:latest
        ports:
          - 8080:80
        options: >-
          --health-cmd "curl -f http://localhost/status/200"
          --health-interval 5s
          --health-timeout 3s
          --health-retries 3

    steps:
      # ... 既存のステップ ...

      - name: Run tests with verification
        working-directory: test_on_k6
        run: npm run ci:verify
        env:
          HTTPBIN_URL: http://localhost:8080
```

### 主要な実装方針

1. **後方互換性の維持**
   - 環境変数`HTTPBIN_URL`で切り替え
   - デフォルト値をローカルに設定

2. **シンプルな構成**
   - httpbinのみを含むminimal Docker Compose
   - 複雑な設定を避ける

3. **ヘルスチェック**
   - コンテナ起動を確実に待つ
   - テスト実行前にサービスが準備完了していることを保証

4. **CI/CD最適化**
   - GitHub ActionsのservicesでDocker Composeを代替
   - イメージキャッシュの活用

## スコープ

### 含むもの

1. **Docker Compose設定**
   - httpbinコンテナ定義
   - ポートマッピング（8080:80）
   - ヘルスチェック

2. **テストコード修正**
   - ベースURL環境変数対応
   - デフォルト値設定

3. **npm スクリプト**
   - Docker起動・停止
   - ローカルテスト実行

4. **GitHub Actions修正**
   - servicesでhttpbin起動
   - 環境変数設定

5. **ドキュメント更新**
   - README.md（ローカル実行方法）
   - 完了ドキュメント

### 含まないもの

1. **複数サービスの追加**
   - データベース
   - メッセージキュー
   - → 必要になったら追加

2. **カスタムhttpbinイメージ**
   - 公式イメージで十分
   - → カスタマイズ不要

3. **本番環境向けDocker設定**
   - テスト専用の設定
   - → 本番デプロイは別タスク

## 影響範囲

### 変更が影響するファイルやコンポーネント

**新規作成**
- `test_on_k6/docker-compose.yml` - Docker Compose設定

**変更**
- `test_on_k6/src/test_all.mbt` - setup()関数の修正
- `test_on_k6/package.json` - npm スクリプト追加
- `.github/workflows/test.yml` - servicesセクション追加、環境変数設定
- `test_on_k6/README.md` - Docker使用方法の説明
- `test_on_k6/.gitignore` - Docker関連ファイル追加（必要に応じて）

**変更なし**
- テストロジック
- 検証スクリプト
- 期待値定義

### 他の機能への影響

**影響あり**
- ローカル開発環境（Dockerが必要）
- CI/CD環境（servicesの追加）

**影響なし**
- MoonBitコンパイル
- 検証ロジック
- 期待値チェック

## 実装手順（概要）

1. **Docker Compose作成**
   - docker-compose.yml作成
   - ローカルで動作確認

2. **テストコード修正**
   - setup()関数の環境変数対応
   - ローカルテスト実行

3. **npm スクリプト追加**
   - docker:up/down/logs
   - test:local/ci:verify:local

4. **GitHub Actions修正**
   - servicesセクション追加
   - 環境変数設定
   - 動作確認

5. **ドキュメント更新**
   - README.md
   - 完了ドキュメント

6. **統合テスト**
   - ローカルで全フロー確認
   - PRでCI動作確認

## リスクと対策

### 想定されるリスク

1. **Dockerのバージョン差異**
   - docker compose vs docker-compose
   - **対策**: docker composeを推奨（Compose V2）

2. **ポート競合**
   - 8080ポートが使用中
   - **対策**: 環境変数でポート変更可能にする

3. **ヘルスチェック失敗**
   - httpbinの起動が遅い
   - **対策**: リトライ回数、間隔を調整

4. **CI環境のリソース制限**
   - Dockerコンテナ起動の遅延
   - **対策**: GitHub Actionsのservicesを使用（最適化済み）

5. **環境変数の設定忘れ**
   - CI環境でHTTPBIN_URLが未設定
   - **対策**: デフォルト値を設定、ドキュメントに明記

## 参考資料

- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [kennethreitz/httpbin](https://hub.docker.com/r/kennethreitz/httpbin/)
- [GitHub Actions Services](https://docs.github.com/en/actions/using-containerized-services/about-service-containers)
- [k6 Environment Variables](https://grafana.com/docs/k6/latest/using-k6/environment-variables/)
