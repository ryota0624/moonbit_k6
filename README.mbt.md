# ryota0624/k6

![Test](https://github.com/ryota0624/k6-moonbit/workflows/Test%20k6%20MoonBit%20Library/badge.svg)

[k6](https://k6.io/)のMoonBitバインディング - モダンな負荷テストツール

## 概要

このライブラリは、k6 JavaScript APIの型安全なMoonBitバインディングを提供します。MoonBitで完全な型安全性を持つ負荷テストを記述し、JavaScriptにコンパイルしてk6で実行できます。

## 機能

- 🎯 k6 APIの完全な型安全バインディング
- 🔧 [@types/k6](https://github.com/DefinitelyTyped/DefinitelyTyped/tree/master/types/k6)の定義をベースに実装
- 📦 [vite-plugin-moonbit](https://github.com/mizchi/vite-plugin-moonbit)でバンドル
- 🐳 Docker Composeのサンプル環境を同梱

## k6モジュールのカバレッジ

このライブラリは、すべてのk6モジュールのバインディング提供を目指しています：

### コアモジュール
- [ ] `k6` - コアAPI（check、fail、group、sleepなど）
- [ ] `k6/global` - グローバル変数（__ENV、__VU、__ITER、openなど）

### ネットワーク＆プロトコル
- [ ] `k6/http` - HTTPクライアント
- [ ] `k6/websockets` - WebSocketクライアント
- [ ] `k6/ws` - WebSocket代替API
- [ ] `k6/net/grpc` - gRPCクライアント

### データ＆エンコーディング
- [ ] `k6/data` - データ処理ユーティリティ
- [ ] `k6/encoding` - エンコード/デコードユーティリティ
- [ ] `k6/crypto` - 暗号化関数

### テスト＆メトリクス
- [ ] `k6/metrics` - カスタムメトリクス
- [ ] `k6/options` - テスト設定
- [ ] `k6/execution` - テスト実行コンテキスト

### ユーティリティ
- [ ] `k6/html` - HTMLパーサー
- [ ] `k6/timers` - タイマー関数
- [ ] `k6/secrets` - シークレット管理
- [ ] `k6/browser` - ブラウザ自動化（実験的機能）
- [ ] `k6/experimental` - 実験的機能

## はじめに

_（準備中 - example/ディレクトリのサンプルを参照してください）_

## テスト

このライブラリには自動化されたテストスイートが含まれています：

- **test_on_k6/**: MoonBitで書いたシナリオが実際のk6ランタイム上で動作するかを検証
- 期待値駆動のテスト設計（expectations.json）
- GitHub Actionsによる自動CI実行

詳細は[test_on_k6/README.md](test_on_k6/README.md)を参照してください。

## 開発

実装計画については[docs/steering/20260214_k6_moonbit_facade.md](docs/steering/20260214_k6_moonbit_facade.md)を参照してください。

## ライセンス

Apache-2.0
