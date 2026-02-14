# Goal
https://github.com/DefinitelyTyped/DefinitelyTyped/tree/master/types/k6 を参考にしてk6のmoonbitファサードを作成する

# TODO

## Phase 1: Setup & Planning ✅

- [x] ~~k6の型定義をプロジェクトに取り込む~~
  - [x] ~~exampleディレクトリにpackage.jsonを作成~~
  - [x] ~~@types/k6をdevDependencyとして追加~~
- [x] ~~作業予定のディレクトリをREADMEとTODOに記載~~
  - [x] ~~DefinitelyTypedのk6型定義の構造を調査~~
  - [x] ~~16モジュールをREADMEにリスト化~~

## Phase 2: FFI Implementation (Priority Order)

### Priority 1: Core & HTTP (必須機能)
- [x] ~~`k6` コアAPI実装~~
  - [x] ~~check() - テスト結果の検証~~
  - [x] ~~fail() - テスト失敗~~
  - [x] ~~group() - グループ化~~
  - [x] ~~sleep() - 待機~~
  - [x] ~~randomSeed() - 乱数シード~~
- [x] ~~`k6/global` グローバル変数・関数~~
  - [x] ~~__ENV - 環境変数~~
  - [x] ~~__VU - VU番号~~
  - [x] ~~__ITER - イテレーション番号~~
  - [x] ~~open() - ファイル読み込み~~
- [x] ~~`k6/http` HTTP クライアント~~
  - [x] ~~request() - HTTPリクエスト~~
  - [x] ~~get(), post(), put(), delete(), patch()~~
  - [x] ~~batch() - 並列リクエスト~~
  - [x] ~~Response型~~
  - [x] ~~Params型~~

### Priority 2: Metrics & Options (設定・計測)
- [x] ~~`k6/metrics` カスタムメトリクス~~
  - [x] ~~Counter~~
  - [x] ~~Gauge~~
  - [x] ~~Rate~~
  - [x] ~~Trend~~
- [x] ~~`k6/options` テスト設定~~
  - [x] ~~Options型~~
  - [x] ~~Thresholds~~
  - [x] ~~Scenarios~~

### Priority 3: Additional Protocols
- [x] ~~`k6/websockets` WebSocketクライアント~~
- [x] ~~`k6/ws` WebSocket代替API~~
- [ ] `k6/net/grpc` gRPCクライアント（複雑なため未実装）

### Priority 4: Utilities
- [x] ~~`k6/data` データ処理~~
- [x] ~~`k6/encoding` エンコーディング~~
- [x] ~~`k6/crypto` 暗号化~~
- [ ] `k6/html` HTMLパース（未実装）
- [ ] `k6/timers` タイマー（未実装）
- [x] ~~`k6/execution` 実行コンテキスト~~

### Priority 5: Advanced Features
- [ ] `k6/secrets` シークレット管理
- [ ] `k6/experimental` 実験的機能
- [ ] `k6/browser` ブラウザ自動化

## Phase 3: Example & Tooling

- [x] ~~JavaScriptのFFI統合~~
  - [x] ~~https://github.com/mizchi/js.mbt を依存関係に追加~~
  - [x] ~~FFI基盤の整備~~
- [x] ~~exampleディレクトリの実装~~
  - [x] ~~MoonBitで書いたk6スクリプトのサンプル~~
  - [x] ~~vite-plugin-moonbitでバンドル設定~~
  - [x] ~~export default / export options の出力確認~~
  - [x] ~~docker-compose.ymlの作成~~
    - [x] ~~負荷テスト対象のサンプルサーバ~~
    - [x] ~~k6実行環境~~
  - [x] ~~実行手順のドキュメント~~

## Phase 4: Wrapper API

- [x] ~~k6のAPIをラップして、より使いやすいAPIを提供する~~
  - [x] ~~MoonBit流の型安全なAPI設計~~
  - [x] ~~Builder パターンの検討~~
  - [x] ~~エラーハンドリングの改善~~

## Documentation

- [x] ~~Steeringドキュメント作成~~
- [ ] 各モジュールのドキュメント作成
- [x] ~~完了ドキュメント作成~~

## 実装完了済み（2026-02-14）

✅ フェーズ1: Setup & Planning
✅ k6コアAPI実装（check, fail, group, sleep, random_seed, env, vu, iter, open）
✅ FFI基盤整備（mizchi/js統合）
✅ Example環境構築（docker-compose含む）
✅ k6互換出力形式対応（export default / export options）
✅ Viteビルド対応（example-vite）
✅ Moon Buildビルド対応（example-moonbit）
✅ Priority 1: Core & HTTP - 完全完了
  - k6/http モジュール（GET, POST, PUT, PATCH, DELETE, request, batch）
  - Response型、Params型
✅ Priority 2: Metrics & Options - 完全完了
  - k6/metrics モジュール（Counter, Gauge, Rate, Trend）
  - k6/options モジュール（Options型, Thresholds, Scenarios）
✅ Priority 3: Additional Protocols - 部分完了
  - k6/ws モジュール（WebSocket基本機能）
✅ Priority 4: Utilities - 大部分完了
  - k6/encoding（base64エンコード/デコード）
  - k6/crypto（ハッシュ関数、HMAC、ランダムバイト）
  - k6/data（SharedArray）
  - k6/execution（実行コンテキスト情報）
✅ Phase 4: Wrapper API - 完全完了
  - HTTP Request Builder（流暢なAPI）
  - 型安全なCheck API
  - テストライフサイクル管理
  - メトリクス便利関数

## 次のステップ

### 最優先: k6/http モジュールの実装
基本的なHTTPリクエスト機能を実装し、実際の負荷テストが可能な状態にする。

- [ ] request() - HTTPリクエスト
- [ ] get(), post(), put(), delete(), patch()
- [ ] Response型
- [ ] Params型
