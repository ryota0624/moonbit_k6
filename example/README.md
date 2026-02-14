# k6 MoonBit Examples

MoonBitでk6負荷テストを記述する方法を示すサンプル集です。

## ディレクトリ構成

このディレクトリには、2つの異なるビルド方法のサンプルが含まれています:

### 📁 example-moonbit/ (推奨)

**Moon Build** を使用した従来の方法です。

- シンプルで分かりやすい
- 追加の依存関係が少ない
- 安定した動作

**使い方:**
```bash
cd example-moonbit
npm install
npm run build
npm run k6
```

詳細は [example-moonbit/README.md](./example-moonbit/README.md) を参照してください。

### 📁 example-vite/ (実験的)

**Vite + vite-plugin-moonbit** を使用したモダンな方法です。

- モダンなビルドツールチェーン
- ホットリロード対応
- プラグインによる拡張性

**使い方:**
```bash
cd example-vite
npm install --legacy-peer-deps
npm run build
npm run k6
```

詳細は [example-vite/README.md](./example-vite/README.md) を参照してください。

## どちらを使うべきか？

### example-moonbit を推奨する場合
- ✅ シンプルで確実なビルドが必要
- ✅ 追加の依存関係を避けたい
- ✅ 本番環境での利用

### example-vite を推奨する場合
- ⚡ 開発時のホットリロードが欲しい
- 🔧 Viteエコシステムとの統合が必要
- 🧪 実験的な機能を試したい

**初めての方は `example-moonbit/` から始めることをお勧めします。**

## 共通の内容

両方のサンプルは同じMoonBitコードを使用しています:

- `src/script.mbt`: k6負荷テストスクリプト
- `src/moon.pkg`: パッケージ設定
- `moon.mod.json`: モジュール設定

違いはビルド方法のみです。

## 必要なもの

- [MoonBit](https://www.moonbitlang.com/) がインストールされていること
- Node.js と npm/pnpm
- Docker と Docker Compose (オプション)
- k6 (ローカル実行の場合)

## 次のステップ

サンプルを実行した後は:

1. `src/script.mbt` を編集してテストシナリオをカスタマイズ
2. `k6/http` モジュール実装後、HTTPリクエストを追加
3. カスタムメトリクスやしきい値を設定
4. 実際のサービスに対して負荷テストを実行
