# ryota0624/k6

[k6](https://k6.io/)のMoonBitバインディング 

## 概要

このライブラリは、k6 JavaScript APIの型安全なMoonBitバインディングを提供します。MoonBitで完全な型安全性を持つ負荷テストを記述し、JavaScriptにコンパイルしてk6で実行できます。

## 提供機能

### コアモジュール
- [x] `k6` - コアAPI（check、fail、group、sleepなど）
- [x] `k6/global` - グローバル変数（__ENV、__VU、__ITER、openなど）

### ネットワーク＆プロトコル
- [x] `k6/http` - HTTPクライアント
- [ ] `k6/websockets` - WebSocketクライアント
- [x] `k6/ws` - WebSocket代替API
- [ ] `k6/net/grpc` - gRPCクライアント

### データ＆エンコーディング
- [x] `k6/data` - データ処理ユーティリティ
- [x] `k6/encoding` - エンコード/デコードユーティリティ
- [x] `k6/crypto` - 暗号化関数

### テスト＆メトリクス
- [x] `k6/metrics` - カスタムメトリクス
- [x] `k6/options` - テスト設定
- [x] `k6/execution` - テスト実行コンテキスト

### ユーティリティ
- [ ] `k6/html` - HTMLパーサー
- [ ] `k6/timers` - タイマー関数
- [ ] `k6/secrets` - シークレット管理
- [ ] `k6/browser` - ブラウザ自動化（実験的機能）
- [ ] `k6/experimental` - 実験的機能

## はじめに

_（準備中 - example/ディレクトリのサンプルを参照してください）_

## 開発

実装計画については[docs/steering/20260214_k6_moonbit_facade.md](docs/steering/20260214_k6_moonbit_facade.md)を参照してください。

## ライセンス

Apache-2.0
