# Steering: テスト結果の自動検証

作成日: 2026-02-14

## 目的・背景

### なぜこの作業が必要なのか

現在、test_on_k6は以下のフローで動作しています：

1. `npm run test` でk6を実行
2. k6がテキスト形式のレポートを出力
3. **開発者が目視で期待値と比較** ← ここを自動化したい

目視確認には以下の問題があります：
- **人的ミスのリスク**: 見落とし、読み間違い
- **CI/CDでの判定不可**: 自動化されていないため、CIで合否を判定できない
- **スケーラビリティの欠如**: テストが増えると確認が大変

### 解決しようとしている問題

1. **手動確認の負担**
   - 毎回レポートを目視で確認するのは非効率
   - テスト数が増えると確認項目が増える

2. **CI/CDでの自動判定ができない**
   - k6は常に終了コード0で終了（テスト実行成功）
   - checkが失敗してもCI上では成功扱い
   - 期待値との差異を検出できない

3. **回帰テストの自動化不足**
   - ライブラリ変更時に既存機能が壊れても気づけない
   - PRレビュー時に手動確認が必要

## ゴール

### 作業完了時に達成されるべき状態

1. **期待値の定義ファイル**
   - `test_on_k6/expectations.json`
   - テストごとの期待値を記述
   - メトリクス名、期待値、許容誤差

2. **自動検証スクリプト**
   - `test_on_k6/verify.js` (Node.js)
   - k6のJSON出力を解析
   - 期待値と比較
   - 差異があればエラーで終了

3. **CI統合**
   - `npm run ci:verify` コマンド
   - インストール → ビルド → テスト → **検証**
   - 検証失敗時は exit code 1

4. **ドキュメント更新**
   - README.mdに検証方法を追加
   - トラブルシューティング

### 成功の基準

- [ ] expectations.jsonが作成され、期待値が定義されている
- [ ] verify.jsが実装され、summary.jsonを解析できる
- [ ] 期待値と一致する場合、verify.jsが終了コード0で終了
- [ ] 期待値と異なる場合、verify.jsが終了コード1で終了し、差異を出力
- [ ] `npm run ci:verify` で全フローが自動実行される
- [ ] CIで失敗時に適切なエラーメッセージが表示される

## アプローチ

### 採用する技術的アプローチ

#### 1. k6のJSON出力を活用

k6は `--summary-export` オプションでメトリクスをJSON形式で出力できます：

```bash
k6 run --summary-export=summary.json dist/test.js
```

**summary.jsonの例:**
```json
{
  "metrics": {
    "iterations": {
      "type": "counter",
      "contains": "default",
      "values": {
        "count": 3,
        "rate": 0.853277
      }
    },
    "http_reqs": {
      "type": "counter",
      "contains": "default",
      "values": {
        "count": 6,
        "rate": 1.706554
      }
    },
    "checks": {
      "type": "rate",
      "contains": "default",
      "values": {
        "rate": 1.0,
        "passes": 9,
        "fails": 0
      }
    },
    "test_counter": {
      "type": "counter",
      "contains": "default",
      "values": {
        "count": 3,
        "rate": 0.853277
      }
    }
  }
}
```

#### 2. 期待値の定義形式

**expectations.json:**
```json
{
  "testName": "k6 MoonBit Library Test",
  "expectations": [
    {
      "metric": "iterations",
      "path": "metrics.iterations.values.count",
      "expected": 3,
      "type": "exact"
    },
    {
      "metric": "http_reqs",
      "path": "metrics.http_reqs.values.count",
      "expected": 6,
      "type": "exact"
    },
    {
      "metric": "checks",
      "path": "metrics.checks.values.rate",
      "expected": 1.0,
      "type": "exact"
    },
    {
      "metric": "checks_passes",
      "path": "metrics.checks.values.passes",
      "expected": 9,
      "type": "exact"
    },
    {
      "metric": "checks_fails",
      "path": "metrics.checks.values.fails",
      "expected": 0,
      "type": "exact"
    },
    {
      "metric": "test_counter",
      "path": "metrics.test_counter.values.count",
      "expected": 3,
      "type": "exact"
    },
    {
      "metric": "test_requests",
      "path": "metrics.test_requests.values.count",
      "expected": 6,
      "type": "exact"
    },
    {
      "metric": "http_req_failed",
      "path": "metrics.http_req_failed.values.rate",
      "expected": 0.0,
      "type": "exact"
    }
  ]
}
```

**type の種類:**
- `exact`: 完全一致
- `min`: 最小値以上
- `max`: 最大値以下
- `range`: 範囲内（将来の拡張）

#### 3. 検証スクリプトの実装（MoonBit）

**ディレクトリ構成:**
```
test_on_k6/
├── verify/
│   ├── moon.mod.json
│   ├── src/
│   │   ├── moon.pkg
│   │   └── main.mbt       # 検証ロジック
│   └── _build/
│       └── js/
│           └── release/
│               └── verify.js  # コンパイル後
├── summary.json
└── expectations.json
```

**verify/src/main.mbt:**
```moonbit
// FFI: Node.js fs module
extern "js" fn read_file(path : String) -> String =
  #|(path) => require('fs').readFileSync(path, 'utf8')

extern "js" fn console_log(msg : String) -> Unit =
  #|(msg) => console.log(msg)

extern "js" fn console_error(msg : String) -> Unit =
  #|(msg) => console.error(msg)

extern "js" fn process_exit(code : Int) -> Unit =
  #|(code) => process.exit(code)

///| データ構造定義（derive(FromJson)を使用）

// expectations.json の構造
struct Expectation {
  metric : String
  path : String
  expected : Double
  type_ : String  // "exact", "min", "max"
} derive(FromJson)

struct ExpectationsFile {
  testName : String
  expectations : Array[Expectation]
} derive(FromJson)

// summary.json の構造
struct MetricValues {
  count : Double?
  rate : Double?
  passes : Int?
  fails : Int?
} derive(FromJson)

struct Metric {
  type_ : String?  // "type" はキーワードなので type_ を使用
  contains : String?
  values : MetricValues
} derive(FromJson)

struct Summary {
  metrics : Map[String, Metric]
} derive(FromJson)

// 検証失敗時のデータ構造
struct Failure {
  metric : String
  expected : Double
  actual : Double
}

// メイン関数
pub fn main() -> Unit {
  // ファイル読み込み
  let summary_str = read_file("summary.json")
  let expectations_str = read_file("expectations.json")

  // JSON解析してJsonValueに
  let summary_json = match @json.parse(summary_str) {
    Ok(v) => v
    Err(e) => {
      console_error("Failed to parse summary.json: \{e}")
      process_exit(1)
      return
    }
  }

  let expectations_json = match @json.parse(expectations_str) {
    Ok(v) => v
    Err(e) => {
      console_error("Failed to parse expectations.json: \{e}")
      process_exit(1)
      return
    }
  }

  // FromJsonを使ってstructにデシリアライズ
  let summary = match Summary::from_json(summary_json) {
    Ok(s) => s
    Err(e) => {
      console_error("Failed to deserialize summary.json: \{e}")
      process_exit(1)
      return
    }
  }

  let expectations_file = match ExpectationsFile::from_json(expectations_json) {
    Ok(e) => e
    Err(e) => {
      console_error("Failed to deserialize expectations.json: \{e}")
      process_exit(1)
      return
    }
  }

  let mut all_passed = true
  let mut failures : Array[Failure] = []

  // 各期待値をチェック
  for exp in expectations_file.expectations {
    // パスから値を取得
    match get_value_from_summary(summary, exp.path) {
      Some(actual_value) => {
        // 期待値と比較
        if not(check_expectation(exp.type_, exp.expected, actual_value)) {
          all_passed = false
          failures.push({ metric: exp.metric, expected: exp.expected, actual: actual_value })
        }
      }
      None => {
        console_error("Failed to get value at path: \{exp.path}")
        all_passed = false
      }
    }
  }

  // 結果出力
  if all_passed {
    console_log("✅ All expectations passed!")
    process_exit(0)
  } else {
    console_error("❌ Some expectations failed:")
    for failure in failures {
      console_error("  - \{failure.metric}:")
      console_error("      Expected: \{failure.expected}")
      console_error("      Actual:   \{failure.actual}")
    }
    process_exit(1)
  }
}

// ヘルパー関数: Summaryから値を取得
fn get_value_from_summary(summary : Summary, path : String) -> Double? {
  // path例: "metrics.http_reqs.values.count"
  let parts = path.split(".")

  if parts.length() < 4 {
    return None
  }

  // parts[0] は "metrics"
  // parts[1] は メトリクス名 (例: "http_reqs")
  // parts[2] は "values"
  // parts[3] は フィールド名 (例: "count")

  let metric_name = parts[1]
  let field_name = parts[3]

  match summary.metrics.get(metric_name) {
    Some(metric) => {
      match field_name {
        "count" => metric.values.count
        "rate" => metric.values.rate
        "passes" => match metric.values.passes {
          Some(p) => Some(p.to_double())
          None => None
        }
        "fails" => match metric.values.fails {
          Some(f) => Some(f.to_double())
          None => None
        }
        _ => None
      }
    }
    None => None
  }
}

// ヘルパー関数: 期待値チェック
fn check_expectation(type_ : String, expected : Double, actual : Double) -> Bool {
  match type_ {
    "exact" => actual == expected
    "min" => actual >= expected
    "max" => actual <= expected
    _ => {
      console_error("Unknown expectation type: \{type_}")
      false
    }
  }
}
```

**verify/moon.mod.json:**
```json
{
  "name": "ryota0624/k6-verify",
  "version": "0.1.0",
  "source": "src",
  "deps": {},
  "preferred-target": "js"
}
```

**注:** moonbitlang/core/json はコアモジュールなので、依存関係に明示的な記述は不要です。

**verify/src/moon.pkg:**
```moonbit
import {
  "moonbitlang/core/json" @json,
}

options(
  "supported-targets": [ "js" ],
  link: {
    "js": {
      "exports": [],
      "format": "esm",
    },
  },
)
```

**主要なポイント:**

1. **derive(FromJson)の使用**
   - structに`derive(FromJson)`を付けると、自動的に`from_json`メソッドが生成される
   - `StructName::from_json(json_value) -> Result[StructName, String]`
   - 型安全なデシリアライズ

2. **構造の事前定義**
   - expectations.json: `ExpectationsFile` struct
   - summary.json: `Summary` struct
   - JSONの構造が型として明示的に定義される

3. **エラーハンドリング**
   - `@json.parse()` は `Result[JsonValue, ParseError]` を返す
   - `from_json()` は `Result[Struct, String]` を返す
   - 2段階のエラーチェック（パース → デシリアライズ）

4. **Option型の活用**
   - summary.jsonは動的なメトリクスを含むため、Option型を使用
   - 存在しないメトリクスに対する安全な処理

#### 4. npmスクリプトの拡張

**package.json:**
```json
{
  "scripts": {
    "prebuild": "moon build --target js --release",
    "build": "vite build",
    "build:verify": "cd verify && moon build --target js --release",
    "test": "k6 run dist/test.js",
    "test:json": "k6 run --summary-export=summary.json dist/test.js",
    "verify": "node verify/_build/js/release/verify.js",
    "ci": "npm install && npm run build && npm run test",
    "ci:verify": "npm run build && npm run build:verify && npm run test:json && npm run verify"
  }
}
```

**実行フロー:**
```bash
npm run ci:verify
  ↓
1. npm run build           # テストコードをビルド
2. npm run build:verify    # 検証スクリプトをビルド
3. npm run test:json       # k6実行 → summary.json生成
4. npm run verify          # MoonBit検証スクリプト実行
```

### 主要な実装方針

1. **シンプルな実装から開始**
   - まずは `exact` 型のみサポート
   - 複雑な比較ロジックは後回し

2. **明確なエラーメッセージ**
   - どのメトリクスが期待値と異なるか明示
   - 期待値と実際の値を並べて表示

3. **段階的な拡張**
   - Phase 1: exact型の実装
   - Phase 2: min/max型の実装
   - Phase 3: 許容誤差の実装（浮動小数点）

4. **CI/CDフレンドリー**
   - 終了コードで成功/失敗を判定
   - エラーメッセージはstderrに出力
   - JSONフォーマットの出力オプション（将来）

## スコープ

### 含むもの

1. **期待値定義ファイル**
   - `expectations.json`
   - 現在のテストスイートの期待値

2. **検証スクリプト**
   - `verify.js`
   - exact型の比較
   - エラー出力

3. **npmスクリプト**
   - `npm run verify`
   - `npm run ci:verify`

4. **ドキュメント**
   - README.mdの更新
   - 検証方法の説明
   - トラブルシューティング

5. **初期テスト**
   - 期待値一致時の動作確認
   - 期待値不一致時の動作確認

### 含まないもの

1. **複雑な比較ロジック**
   - 正規表現マッチング
   - カスタム比較関数
   - → 必要になったら追加

2. **複数テストファイルのサポート**
   - 現在はtest_all.mbtのみ
   - → テストが増えたら対応

3. **グラフィカルなレポート**
   - HTML形式のレポート
   - → 将来の拡張

4. **レポートの保存・履歴管理**
   - 過去のテスト結果との比較
   - → 別タスクとして検討

## 影響範囲

### 変更が影響するファイルやコンポーネント

**新規作成**
- `test_on_k6/expectations.json` - 期待値定義
- `test_on_k6/verify/` - 検証スクリプト（MoonBit）
  - `verify/moon.mod.json`
  - `verify/src/moon.pkg`
  - `verify/src/main.mbt`
  - `verify/_build/` (ビルド成果物、git除外)

**変更**
- `test_on_k6/package.json` (スクリプト追加)
- `test_on_k6/README.md` (検証方法の追加)
- `test_on_k6/.gitignore` (verify/_build/ を追加)

**変更なし**
- テストコード（test_all.mbt）
- ビルド設定（vite.config.js, moon.mod.json）

### 他の機能への影響

**影響なし**
- 既存のテスト実行フロー（`npm run test`）は変更なし
- CI統合は新しいコマンド（`npm run ci:verify`）として追加
- 既存のワークフローは引き続き使用可能

## 実装手順（概要）

### Phase 1: 基本実装

1. **verify/ディレクトリ構築**
   - moon.mod.json作成
   - src/moon.pkg作成
   - ディレクトリ構造の整備

2. **expectations.json作成**
   - 現在のテストの期待値を定義
   - exact型のみ

3. **verify/src/main.mbt実装**
   - FFI定義（fs, console, process.exit）
   - ファイル読み込みロジック
   - JSON解析（@core.Any）
   - 期待値との比較ロジック
   - エラー出力

4. **ビルド・動作確認**
   - `moon build --target js`
   - 期待値一致時: exit 0
   - 期待値不一致時: exit 1

5. **npmスクリプト追加**
   - `npm run build:verify`
   - `npm run verify`
   - `npm run ci:verify`

### Phase 2: ドキュメント更新

1. **README.md更新**
   - 検証方法の説明
   - expectations.jsonの編集方法
   - トラブルシューティング

2. **完了ドキュメント作成**
   - 実装内容の記録

### Phase 3: 拡張機能（オプション）

1. **min/max型のサポート**
   - 範囲チェック

2. **許容誤差の実装**
   - 浮動小数点の比較

3. **詳細なエラーメッセージ**
   - 差分の%表示

## リスクと対策

### 想定されるリスク

1. **k6のJSON出力形式の変更**
   - k6のバージョンアップでフォーマットが変わる可能性
   - **対策**: k6のバージョンを固定、変更時にverify/src/main.mbtを更新

2. **ネットワーク遅延によるメトリクスの変動**
   - http_req_durationなどは環境依存
   - **対策**: 時間系メトリクスは検証対象外、またはmin型で閾値チェック

3. **期待値の保守コスト**
   - テスト変更時にexpectations.jsonも更新が必要
   - **対策**: ドキュメントで明記、テスト失敗時のエラーメッセージで誘導

4. **MoonBitのFFI複雑性**
   - Node.js APIをFFI経由で呼び出す必要がある
   - **対策**: シンプルなFFI定義から開始、必要に応じて拡張

5. **JSON解析の型安全性**
   - @json.JsonValue型を使用し、パターンマッチで型安全にアクセス
   - Result型とOption型でエラーハンドリング
   - **対策**: 各ステップで適切なエラーチェックを実施

6. **MoonBitのString操作の制限**
   - 文字列操作がJavaScriptより制限される可能性
   - **対策**: 必要な機能をFFIで補完

## 代替案の検討

### 代替案1: k6のthresholdsを使う

k6のthresholds機能を使えば、k6自体が検証してくれます：

```moonbit
pub fn options() -> @core.Any {
  let thresholds = Map::new()
  thresholds.set("iterations", ["count==3"])
  thresholds.set("http_reqs", ["count==6"])

  @k6.Options::default()
    .thresholds(thresholds)
    .to_js()
}
```

**メリット:**
- 外部スクリプト不要
- k6ネイティブ機能

**デメリット:**
- MoonBitコード内に期待値がハードコード
- カスタムメトリクスのthresholds設定が複雑
- エラーメッセージがわかりにくい

**結論:** 外部検証スクリプトの方が柔軟性が高い

### 代替案2: MoonBitで検証スクリプトを書く

verify.jsの代わりにMoonBitで実装：

**メリット:**
- MoonBitのみで完結（プロジェクト全体が一貫）
- 型安全な実装
- MoonBitの練習・実証

**デメリット:**
- JSONパースのライブラリが必要（mizchi/jsで対応可能）
- Node.js環境でのファイルI/OをFFI経由で実装

**結論:** ✅ **MoonBitで実装する**（ユーザー要求）

## 参考資料

- [k6 JSON Export](https://grafana.com/docs/k6/latest/results-output/end-of-test/json/)
- [k6 Thresholds](https://grafana.com/docs/k6/latest/using-k6/thresholds/)
- test_on_k6/README.md
- test_on_k6/src/test_all.mbt
