# k6 MoonBit Example

MoonBitでk6負荷テストを記述する方法を示すサンプルです。

## 必要なもの

- [MoonBit](https://www.moonbitlang.com/) がインストールされていること
- Node.js と npm/pnpm
- Docker と Docker Compose

## セットアップ

1. 依存関係をインストール:

```bash
npm install
# または
pnpm install
```

2. MoonBitスクリプトをビルド:

```bash
npm run build
# または
pnpm build
```

**ビルド方法（2つの選択肢）:**

### 方法1: Viteビルド（推奨）
```bash
npm run build
```
vite-plugin-moonbitを使用してビルドします。以下の処理が実行されます:
1. Viteがvite-plugin-moonbitを使ってMoonBitコードをコンパイル
2. 出力を `dist/script.js` に生成
3. 自動的にk6互換形式（`export default` と `export options`）に変換

### 方法2: 手動ビルド
```bash
npm run build:manual
```
MoonBitコマンドを直接使用してビルドします。以下の処理が実行されます:
1. `moon build --target js` でコンパイル
2. 出力を `dist/script.js` にコピー
3. k6互換形式に変換

## 負荷テストの実行

### Docker Composeを使う場合

最も簡単な実行方法:

```bash
docker-compose up
```

以下が実行されます:
1. ポート8080でシンプルなnginxサーバを起動
2. サーバに対してk6負荷テストを実行
3. テスト結果を表示

### ローカル実行（Dockerなし）

1. ローカルサーバを起動（任意のHTTPサーバ）:

```bash
# テストサーバを起動
cd server && python -m http.server 8080
```

2. ビルド済みスクリプトでk6を実行:

```bash
k6 run dist/script.js
```

## スクリプトの構造

MoonBitスクリプト（`src/script.mbt`）は以下を実演します:

- `@k6` エイリアスでk6ライブラリをインポート
- JavaScriptオブジェクトとしてテストオプションを定義（k6向けにエクスポート）
- k6グローバル関数の使用（group, sleep, env, vu, iter）
- 基本的な負荷テストの構造
- MoonBitによる型安全なAPI呼び出し

### 仕組み

1. **MoonBitコード**: 型安全なMoonBitで記述
2. **コンパイル**: `moon build --target js` でJavaScriptにコンパイル
3. **後処理**: `scripts/post-build.js` がk6形式に変換:
   - `options`関数をオブジェクトに変換: `const __options = options()`
   - k6互換形式でエクスポート: `export { __options as options, default }`

## カスタマイズ

### テストオプション

`src/script.mbt` の `options` を編集:

```moonbit
pub fn options() -> @core.Any {
  let opts = @core.new_object()
  opts["vus"] = @core.any(10)        // 仮想ユーザー数
  opts["duration"] = @core.any("30s") // テスト期間
  opts
}
```

### テストURL

`TEST_URL` 環境変数を設定:

```bash
TEST_URL=http://example.com k6 run dist/script.js
```

または `docker-compose.yml` で設定:

```yaml
environment:
  - TEST_URL=http://your-server.com
```

## 次のステップ

- `k6/http` モジュール実装後、HTTPリクエストを追加
- カスタムメトリクスの追加
- より複雑なテストシナリオの追加
- チェックとしきい値の実装
