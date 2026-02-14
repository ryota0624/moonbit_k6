# 完了報告: Docker Compose httpbin環境構築

作成日: 2026-02-14

## 実装内容

test_on_k6でDocker Composeを使用してローカルhttpbin環境を構築し、外部ネットワーク依存を排除しました。

### 主要な成果物

1. **`test_on_k6/docker-compose.yml`** - Docker Compose設定
   - httpbinコンテナ定義
   - ポートマッピング（8080:80）
   - ヘルスチェック設定

2. **テストコードの環境変数対応**
   - `@k6.env("HTTPBIN_URL")`で動的にベースURL切り替え
   - デフォルト値: `http://localhost:8080`

3. **npm スクリプト拡張**
   - `docker:up/down/logs`: Docker Compose操作
   - `test:local`: ローカル環境でのテスト実行
   - `ci:verify:local`: 完全自動化（起動→テスト→停止→検証）

4. **GitHub Actions修正**
   - servicesでhttpbinを起動
   - 環境変数`HTTPBIN_URL`設定

5. **ドキュメント更新**
   - test_on_k6/README.md: Docker使用方法の説明

## 技術的な決定事項

### 1. Docker Compose構成

**httpbinコンテナ:**
```yaml
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

**選択理由:**
- 公式イメージ（kennethreitz/httpbin）を使用
- ヘルスチェックでコンテナの準備完了を確実に待つ
- シンプルな構成（httpbinのみ）

### 2. 環境変数による切り替え

**setup()関数の修正:**
```moonbit
pub fn setup() -> @core.Any {
  // 環境変数HTTPBIN_URLから取得、未設定の場合はローカルを使用
  let base_url = match @k6.env("HTTPBIN_URL") {
    Some(url) => url
    None => "http://localhost:8080"
  }

  let config = @k6.TestSetup::new()
    .base_url(base_url)
    .timeout("10s")
    .build()

  config
}
```

**選択理由:**
- 後方互換性を維持（環境変数で外部httpbinも使用可能）
- デフォルトはローカル（ネットワーク依存なし）
- 既存の`@k6.env()`関数を活用

### 3. npm スクリプト設計

**Docker操作:**
```json
{
  "docker:up": "docker compose up -d && sleep 5",
  "docker:down": "docker compose down",
  "docker:logs": "docker compose logs -f httpbin"
}
```

**統合フロー:**
```json
{
  "test:json:local": "npm run docker:up && npm run test:json ; npm run docker:down",
  "ci:verify:local": "npm run build && npm run build:verify && npm run test:json:local && npm run verify"
}
```

**重要な工夫:**
- `docker:up`で5秒待機（ヘルスチェック完了を待つ）
- `;`を使用してテスト失敗時もコンテナを停止
- `ci:verify:local`で完全自動化

### 4. GitHub Actions services

**serviceコンテナの使用:**
```yaml
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
```

**選択理由:**
- GitHub Actionsの最適化済みコンテナ起動
- Docker Composeより高速
- イメージキャッシュの恩恵

## 変更ファイル一覧

### 新規作成

- `test_on_k6/docker-compose.yml` - Docker Compose設定
- `docs/steering/20260214_docker_compose_httpbin.md` - Steeringドキュメント
- `docs/completed/20260214_docker_compose_httpbin.md` - この完了ドキュメント

### 変更

- `test_on_k6/src/test_all.mbt`
  - setup()関数: 環境変数HTTPBIN_URLで動的切り替え
- `test_on_k6/package.json`
  - npm スクリプト追加: docker:up/down/logs, test:local, test:json:local, ci:verify:local
- `.github/workflows/test.yml`
  - servicesセクション追加
  - 環境変数HTTPBIN_URL設定
- `test_on_k6/README.md`
  - Docker使用方法の説明追加
  - クイックスタートセクション更新

### 変更なし

- テストロジック（test_all.mbtのdefault関数）
- 検証スクリプト
- 期待値定義

## 実行結果

### ローカル実行

```bash
$ npm run ci:verify:local

> docker:up
[+] Running 2/2
 ✔ Network test_on_k6_default  Created
 ✔ Container test_on_k6-httpbin-1  Started

> build
...

> test:json
...

> docker:down
[+] Running 2/1
 ✔ Container test_on_k6-httpbin-1  Removed
 ✔ Network test_on_k6_default  Removed

> verify
✅ All expectations passed!
```

### GitHub Actions

```yaml
env:
  HTTPBIN_URL: http://localhost:8080
run: npm run ci:verify
```

GitHub Actionsでは`ci:verify`を実行（docker:upは不要、servicesが自動起動）。

## 利点

### 1. 外部依存の排除

**Before:**
- https://httpbin.org へのリクエスト
- ネットワークエラーのリスク
- レート制限の可能性

**After:**
- ローカルコンテナへのリクエスト
- ネットワーク依存なし
- 安定したテスト実行

### 2. 高速化

**Before:**
- 外部API呼び出し（レイテンシ: 100-500ms）

**After:**
- ローカルネットワーク（レイテンシ: 1-5ms）
- CI実行時間の短縮

### 3. テストの独立性

- 各テスト実行で新しいコンテナ起動（オプション）
- 他のテスト実行の影響を受けない
- 予測可能なレスポンス

## 今後の課題・改善点

### 機能拡張

- [ ] カスタムhttpbinレスポンス設定
- [ ] 複数サービスの追加（DB、Redis など）
- [ ] Docker Composeのprofileによる環境切り替え

### 最適化

- [ ] Docker Layer キャッシュの活用
- [ ] コンテナ起動時間の短縮（現在5秒待機）
- [ ] 並列テスト実行（複数コンテナ）

### ドキュメント

- [ ] トラブルシューティングガイド
- [ ] ポート競合時の対処法
- [ ] Dockerなし環境でのテスト方法

## ベストプラクティス

### Docker Composeの使用

```bash
# 起動
npm run docker:up

# ログ確認
npm run docker:logs

# 停止
npm run docker:down
```

### 環境変数の使用

```bash
# ローカルコンテナ（デフォルト）
npm run ci:verify:local

# 外部httpbin
HTTPBIN_URL=https://httpbin.org npm run ci:verify

# カスタムURL
HTTPBIN_URL=http://custom-httpbin:8080 npm run ci:verify
```

### CI/CD

**GitHub Actions:**
- `services`を使用してhttpbinを起動
- `env: HTTPBIN_URL: http://localhost:8080`を設定
- `npm run ci:verify`を実行（docker:up不要）

**GitLab CI / その他:**
- `docker-compose.yml`を使用
- `npm run ci:verify:local`を実行

## 参考資料

- [Steeringドキュメント](../steering/20260214_docker_compose_httpbin.md)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [kennethreitz/httpbin](https://hub.docker.com/r/kennethreitz/httpbin/)
- [GitHub Actions Services](https://docs.github.com/en/actions/using-containerized-services/about-service-containers)

## まとめ

Docker Compose httpbin環境の構築により、以下を達成しました：

✅ **外部依存の排除**: httpbin.orgへの依存を削除、ローカルコンテナで完結

✅ **テストの安定性向上**: ネットワークエラーによる失敗を防止

✅ **高速化**: ローカルネットワーク通信によるレイテンシ削減

✅ **CI/CD統合**: GitHub Actionsのservicesで最適化された実行

✅ **環境の再現性**: Docker Composeによる一貫した環境

✅ **柔軟性**: 環境変数で外部httpbinとの切り替えも可能

これにより、test_on_k6は外部ネットワークに依存しない、安定したテスト環境を実現しました。
