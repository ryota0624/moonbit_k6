# k6 MoonBit Example (Vite Build)

MoonBitでk6負荷テストを記述する方法を示すサンプルです。

このディレクトリは **Vite + vite-plugin-moonbit** を使用した方法です。従来のMoon Buildを使用する場合は `../example-moonbit/` を参照してください。

**📁 ディレクトリ**: `example/example-vite/`

## 必要なもの

- [MoonBit](https://www.moonbitlang.com/) がインストールされていること
- Node.js と npm/pnpm
- Docker と Docker Compose

## セットアップ

1. 依存関係をインストール:

```bash
npm install --legacy-peer-deps
# または
pnpm install
```

**注意:** `vite-plugin-moonbit`の依存関係の問題により、`--legacy-peer-deps`フラグが必要な場合があります。

2. Viteでビルド:

```bash
npm run build
```

以下の処理が自動的に実行されます:
1. Viteが`vite-plugin-moonbit`を使ってMoonBitコードをコンパイル
2. 出力を `dist/script.js` に生成
3. k6-post-buildプラグインがk6互換形式（`export default` と `export options`）に変換

## 負荷テストの実行

### Docker Composeを使う場合

```bash
npm run k6:docker
# または
docker-compose up
```

### ローカル実行

```bash
npm run k6
# または
k6 run dist/script.js
```

## Viteビルドの特徴

### 利点
- モダンなビルドツールチェーン
- ホットリロード対応（`npm run dev`）
- プラグインによる拡張性

### 制約
- `vite-plugin-moonbit`の依存関係に注意が必要
- 追加の設定が必要な場合がある

## vite.config.js

Vite設定ファイルには以下が含まれています:

- `vite-plugin-moonbit`: MoonBitコードのコンパイル
- `k6-post-build`: k6互換形式への自動変換プラグイン

```javascript
{
  name: "k6-post-build",
  closeBundle() {
    execSync("node scripts/post-build.js");
  },
}
```

## スクリプトの構造

MoonBitスクリプト（`src/script.mbt`）は以下を実演します:

- `@k6` エイリアスでk6ライブラリをインポート
- JavaScriptオブジェクトとしてテストオプションを定義
- k6グローバル関数の使用（group, sleep, env, vu, iter）
- MoonBitによる型安全なAPI呼び出し

## 他のビルド方法

シンプルなMoon Buildについては、`../example/` ディレクトリを参照してください。

## トラブルシューティング

### 依存関係のエラー

```bash
npm install --legacy-peer-deps
```

### ビルドエラー

1. MoonBitが正しくインストールされているか確認
2. `moon.mod.json`と`moon.pkg`が正しく設定されているか確認
3. `vite-plugin-moonbit`のバージョンを確認

## 次のステップ

- `k6/http` モジュール実装後、HTTPリクエストを追加
- カスタムメトリクスの追加
- より複雑なテストシナリオの追加
- チェックとしきい値の実装
