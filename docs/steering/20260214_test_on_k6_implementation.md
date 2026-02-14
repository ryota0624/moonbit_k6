# Steering: test_on_k6ディレクトリの実装

作成日: 2026-02-14

## 目的・背景

### なぜこの作業が必要なのか

現在、プロジェクトルートに実装されているk6ライブラリ（k6.mbt, http.mbt, metrics.mbt など）の動作検証方法が不十分です。

- `moon test`は使用しない（MoonBitの標準テストフレームワークには乗らない）
- 実際のk6ランタイム上で動作確認する必要がある
- example/example-viteはサンプルであり、体系的なテストではない

### 解決しようとしている問題

1. **ライブラリの機能検証が不完全**
   - 各モジュール（http, metrics, checks, lifecycle など）の動作が正しいか確認できていない
   - 実際のk6環境で実行して初めてわかるバグがある可能性

2. **シナリオの意図と実行結果の整合性確認**
   - MoonBitで「HTTPリクエストを5回実行する」と書いたら、本当に5回実行されるか
   - カスタムメトリクス（Counter, Trend等）が正しく記録されるか
   - checkの成功/失敗が期待通りか
   - groupやtagが正しくレポートに反映されるか

3. **回帰テストが困難**
   - 機能追加や修正時に既存機能が壊れていないか確認しづらい
   - k6レポートを使った自動検証が未整備

4. **example と test の混在**
   - example-viteはサンプルとして機能しているが、テストとしては不十分
   - テストとサンプルを分離すべき

## ゴール

### 作業完了時に達成されるべき状態

1. **test_on_k6ディレクトリの構築**
   - vite + vite-plugin-moonbitを使用したビルド環境
   - k6で実行可能なJavaScriptへのトランスパイル

2. **体系的なテストスイートの作成**
   - 各モジュールの主要機能をカバーするテストシナリオ
   - 実際のk6ランタイム上で実行できる

3. **k6レポートを使った検証方法の確立**
   - `npm run test` で全テストを実行
   - k6の出力レポート（text/JSON）で結果を確認
   - 期待値との整合性を検証
   - CI/CDでの実行可能性

### 成功の基準

- [ ] test_on_k6ディレクトリが構築され、ビルドが成功する
- [ ] 以下のモジュールのテストが実装され、k6で実行できる：
  - [ ] k6コアAPI（check, group, sleep など）
  - [ ] k6/http（リクエスト、レスポンス処理）
  - [ ] k6/metrics（Counter, Gauge, Rate, Trend）
  - [ ] Wrapper API（RequestBuilder, check_all など）
- [ ] 各テストで**期待される動作**が明確に定義されている
  - 例: "HTTPリクエストを5回実行する" → `http_reqs=5`を期待
  - 例: "Counterを10回インクリメント" → カスタムメトリクス=10を期待
  - 例: "全checkが成功" → `checks=100%`を期待
- [ ] k6のレポート出力で期待値との整合性が確認できる
  - テキスト形式のレポートで目視確認
  - JSON形式のレポート（`--summary-export`）で解析可能
- [ ] READMEにテスト実行手順と検証方法が記載されている

## アプローチ

### 採用する技術的アプローチ

1. **ディレクトリ構成**
   ```
   test_on_k6/
   ├── package.json          # npm設定
   ├── vite.config.js        # viteビルド設定
   ├── moon.mod.json         # MoonBitモジュール設定
   ├── index.js              # エントリポイント
   ├── src/
   │   ├── moon.pkg          # パッケージ設定（親モジュール依存）
   │   ├── test_core.mbt     # k6コアAPIのテスト
   │   ├── test_http.mbt     # k6/httpのテスト
   │   ├── test_metrics.mbt  # k6/metricsのテスト
   │   └── test_wrapper.mbt  # Wrapper APIのテスト
   └── README.md             # 実行手順
   ```

2. **依存関係の設定**
   - moon.pkg: `{ "is_main": true, "link": { "wasm-gc": {} }, "import": [ "ryota0624/k6" ] }`
   - 親モジュール（プロジェクトルート）のk6ライブラリをインポート
   - vite-plugin-moonbitでビルド

3. **テストシナリオの構造**
   ```moonbit
   // 各テストファイル

   // 期待される動作を定義
   // 期待: http_reqs=5, checks=5/5 (100%)
   pub fn options() -> @core.Any {
     @k6.Options::default()
       .vus(1)           // VU数: 1
       .iterations(5)    // イテレーション: 5回
       .to_js()
   }

   pub fn default(data: @core.Any) -> Unit {
     @k6.group("モジュール名", fn() {
       // 1リクエスト/イテレーション → 合計5リクエスト
       let res = @k6.quick_get("https://test.k6.io")

       // checkで検証 → 5回成功を期待
       @k6.check(res, "status is 200", fn(r) { r.status == 200 })
     })
   }
   ```

4. **テスト実行・検証フロー**
   ```bash
   npm install                   # 依存関係インストール
   npm run build                 # MoonBit → JS変換
   npm run test                  # k6でテスト実行
   # → k6のレポート出力を確認
   # → 期待値と一致するか検証

   # JSON形式で出力（オプション）
   k6 run --summary-export=summary.json dist/test.js
   # → summary.jsonをプログラムで解析可能
   ```

### 主要な実装方針

1. **期待値駆動のテスト設計**
   - 各テストで「期待される動作」をコメントで明記
   - 例: `// 期待: http_reqs=5, custom_counter=10, checks=100%`
   - k6レポートで期待値との整合性を確認

2. **k6レポートを検証の材料にする**
   - テキスト形式: 目視で確認（開発時）
   - JSON形式（`--summary-export`）: プログラムで解析（将来のCI/CD向け）
   - 主な確認項目:
     - `http_reqs`: HTTPリクエスト回数
     - `http_req_duration`: レスポンス時間
     - `checks`: check成功率
     - カスタムメトリクス: Counter, Gauge, Rate, Trend
     - `group_duration`: groupの実行時間

3. **モジュールごとにテストファイルを分割**
   - 各機能領域を独立してテスト
   - 問題の特定が容易
   - 各テストファイルは独立して実行可能

4. **シンプルで明確なシナリオ**
   - 負荷テストではなく、機能確認
   - VU数は1、イテレーション数は5〜10程度
   - 実行時間は数秒（迅速なフィードバック）

5. **段階的な実装**
   - まずコアAPIのテストから開始
   - 動作確認後、他のモジュールを追加

6. **example-viteとの差別化**
   - example-vite: ユーザー向けサンプル（実用的なシナリオ、負荷テスト）
   - test_on_k6: 開発者向けテスト（機能検証、期待値との整合性確認）

## スコープ

### 含むもの

1. **test_on_k6ディレクトリの構築**
   - ビルド環境の整備
   - 依存関係の設定

2. **優先度の高いモジュールのテスト**
   - k6コアAPI（check, group, sleep, fail など）
   - k6/http（GET, POST, Response型）
   - k6/metrics（Counter, Gauge, Rate, Trend）
   - Wrapper API（RequestBuilder, check_all など）

3. **実行・検証の仕組み**
   - ビルドスクリプト
   - テスト実行スクリプト
   - 結果判定

4. **ドキュメント**
   - README.md（実行手順）
   - このSteeringドキュメント
   - 完了ドキュメント（作業後）

### 含まないもの

1. **すべてのモジュールの完全なカバレッジ**
   - 初期実装では主要機能のみ
   - 網羅的なテストは段階的に追加

2. **CI/CD統合**
   - 初期実装ではローカル実行のみ
   - CI/CD統合は別タスクとして後で実装

3. **パフォーマンステスト**
   - 機能の正確性を検証するのが目的
   - 負荷テストは別の目的

4. **ブラウザ自動化テスト**
   - k6/browserは未実装のため対象外

## 影響範囲

### 変更が影響するファイルやコンポーネント

**新規作成**
- `test_on_k6/` ディレクトリ全体
  - package.json
  - vite.config.js
  - moon.mod.json
  - index.js
  - src/*.mbt
  - README.md

**変更なし**
- プロジェクトルートのライブラリコード（k6.mbt, http.mbt など）
  - テストのみ追加、既存コードは変更しない

**軽微な変更の可能性**
- `.gitignore`（test_on_k6のビルド成果物を除外）
- プロジェクトルートのREADME.md（test_on_k6への言及追加）

### 他の機能への影響

**影響なし**
- example/example-vite: 独立したディレクトリのため影響なし
- example/example-moonbit: 同上
- 既存のライブラリコード: 変更しないため影響なし

**相互作用**
- test_on_k6は親モジュール（ryota0624/k6）に依存
- 親モジュールの変更は test_on_k6 のテストに影響する（これは期待される動作）

## 実装手順（概要）

1. **環境構築**
   - test_on_k6ディレクトリ作成
   - package.json, vite.config.js, moon.mod.json 作成

2. **最小構成での動作確認**
   - index.js作成
   - 簡単なテストシナリオ作成
   - ビルド・実行確認

3. **テストの段階的追加**
   - test_core.mbt: コアAPI
   - test_http.mbt: HTTP機能
   - test_metrics.mbt: メトリクス
   - test_wrapper.mbt: Wrapper API

4. **ドキュメント作成**
   - README.md作成
   - 実行手順記載

5. **動作確認**
   - 全テスト実行
   - 結果判定

6. **完了ドキュメント作成**
   - docs/completed/20260214_test_on_k6_implementation.md

## リスクと対策

### 想定されるリスク

1. **k6ランタイムでのFFI動作不良**
   - 対策: example-viteで実績のあるvite-plugin-moonbitを使用

2. **親モジュールへの依存が正しく解決されない**
   - 対策: moon.pkgのimport設定を正確に記述、ビルドログで確認

3. **テストシナリオが複雑になりすぎる**
   - 対策: モジュールごとにファイルを分割、シンプルなテストから開始

4. **テスト結果の判定が難しい**
   - 対策: k6のcheckを活用、終了コードで判定

## k6レポート検証の具体例

### 例1: HTTPリクエスト回数の検証

**テストコード:**
```moonbit
// 期待: http_reqs=5
pub fn options() -> @core.Any {
  @k6.Options::default().vus(1).iterations(5).to_js()
}

pub fn default(_data: @core.Any) -> Unit {
  let _res = @k6.quick_get("https://test.k6.io")
}
```

**期待されるk6レポート:**
```
http_reqs......................: 5       X/s
```

### 例2: カスタムメトリクスの検証

**テストコード:**
```moonbit
// 期待: api_calls=10
let api_calls : @k6.Counter = @k6.create_counter("api_calls")

pub fn options() -> @core.Any {
  @k6.Options::default().vus(1).iterations(10).to_js()
}

pub fn default(_data: @core.Any) -> Unit {
  api_calls.increment()
}
```

**期待されるk6レポート:**
```
api_calls......................: 10      X/s
```

### 例3: Check成功率の検証

**テストコード:**
```moonbit
// 期待: checks=5/5 (100%)
pub fn options() -> @core.Any {
  @k6.Options::default().vus(1).iterations(5).to_js()
}

pub fn default(_data: @core.Any) -> Unit {
  let res = @k6.quick_get("https://test.k6.io")
  @k6.check(res, "status is 200", fn(r) { r.status == 200 })
}
```

**期待されるk6レポート:**
```
checks.........................: 100.00% ✓ 5        ✗ 0
```

### 例4: Groupの実行確認

**テストコード:**
```moonbit
// 期待: "HTTP Tests" groupが表示される
pub fn default(_data: @core.Any) -> Unit {
  @k6.group("HTTP Tests", fn() {
    let _res = @k6.quick_get("https://test.k6.io")
  })
}
```

**期待されるk6レポート:**
```
group_duration.................: avg=XXms min=XXms max=XXms
  { group: HTTP Tests }
```

### JSON出力の活用（将来の自動化向け）

```bash
k6 run --summary-export=summary.json dist/test.js
```

**summary.json の例:**
```json
{
  "metrics": {
    "http_reqs": {
      "values": {
        "count": 5
      }
    },
    "checks": {
      "values": {
        "rate": 1.0,
        "passes": 5,
        "fails": 0
      }
    },
    "api_calls": {
      "values": {
        "count": 10
      }
    }
  }
}
```

このJSON出力を使えば、将来的にプログラムで期待値との比較が可能になります。

## 参考資料

- example/example-vite/（vite設定の参考）
- example/example-vite/README.md（ビルド手順の参考）
- Todo.md（実装済み機能の確認）
- プロジェクトルートの各.mbtファイル（テスト対象のAPI）
- [k6 Metrics](https://grafana.com/docs/k6/latest/using-k6/metrics/)（k6レポートの読み方）
