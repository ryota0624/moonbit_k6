# 完了報告: テスト結果の自動検証

作成日: 2026-02-14

## 実装内容

MoonBitで実装したk6テスト検証スクリプトにより、k6の実行結果を自動的に検証し、期待値との整合性をチェックする機能を実装しました。

### 主要な成果物

1. **verify/ディレクトリ（MoonBit実装）**
   - `verify/src/main.mbt`: 検証ロジック
   - `verify/moon.mod.json`: モジュール設定
   - `verify/src/moon.pkg`: パッケージ設定

2. **期待値定義ファイル**
   - `test_on_k6/expectations.json`: 8つの期待値を定義
     - iterations: 3
     - http_reqs: 6
     - checks_value: 1.0
     - checks_passes: 9
     - checks_fails: 0
     - test_counter: 3
     - test_requests: 6
     - http_req_failed: 0.0

3. **CI統合**
   - `npm run ci:verify`: ワンコマンドで全フロー実行
   - 検証失敗時にexit code 1で終了

4. **ドキュメント**
   - README.md更新（自動検証機能の説明）
   - Steeringドキュメント
   - この完了ドキュメント

## 技術的な決定事項

### 1. MoonBitでの実装

**選択:** MoonBitで検証スクリプトを実装

**理由:**
- プロジェクト全体の一貫性
- MoonBitの実践的な使用例
- `derive(FromJson)`による型安全なデシリアライズ

**課題と解決:**
- JSONモジュールのAPIが不明確 → try-catchとguard構文で対処
- ES module環境でのrequire → verify/package.jsonで"type": "commonjs"指定
- summary.jsonの構造が想定と異なる → 実際の構造に合わせてstruct修正

### 2. データ構造（derive(FromJson)）

**expectations.json:**
```moonbit
struct Expectation {
  metric : String
  path : String
  expected : Double
  type_ : String
} derive(FromJson)

struct ExpectationsFile {
  testName : String
  expectations : Array[Expectation]
} derive(FromJson)
```

**summary.json:**
```moonbit
struct Metric {
  count : Double?
  rate : Double?
  passes : Int?
  fails : Int?
  value : Double?
} derive(FromJson)

struct Summary {
  metrics : Map[String, Metric]
} derive(FromJson)
```

**重要な発見:**
- k6のsummary.jsonは`metrics.<name>.count`という構造（`values`ネストなし）
- MoonBitの`type_`フィールドはJSONの`type_`にマッピング（`type`キーワード回避）

### 3. パス解析

期待値のパス形式：
```
metrics.<metric_name>.<field_name>
例: metrics.http_reqs.count
```

実装：
```moonbit
fn get_value_from_summary(summary : Summary, path : String) -> Double? {
  let parts = path.split(".").collect()
  let metric_name = parts[1].to_string()
  let field_name = parts[2].to_string()

  match summary.metrics.get(metric_name) {
    Some(metric) => match field_name {
      "count" => metric.count
      "passes" => metric.passes.map(fn(p) { p.to_double() })
      // ...
    }
  }
}
```

### 4. エラーハンドリング

**アプローチ:** `try?`とguard構文を組み合わせ

```moonbit
let parse_result = try? @json.parse(summary_str)
guard parse_result is Ok(json) else {
  console_error("Failed to parse summary.json")
  process_exit(1)
  abort("parse failed")
}
```

### 5. FFI（Foreign Function Interface）

Node.js APIをFFI経由で呼び出し：
```moonbit
extern "js" fn read_file(path : String) -> String =
  #|(path) => require('fs').readFileSync(path, 'utf8')

extern "js" fn console_log(msg : String) -> Unit =
  #|(msg) => console.log(msg)

extern "js" fn process_exit(code : Int) -> Unit =
  #|(code) => process.exit(code)
```

## 変更ファイル一覧

### 新規作成

- `test_on_k6/verify/` - 検証スクリプト（MoonBit）
  - `moon.mod.json`
  - `package.json` (`"type": "commonjs"`)
  - `src/moon.pkg`
  - `src/main.mbt`
- `test_on_k6/expectations.json` - 期待値定義
- `docs/steering/20260214_test_verification_automation.md` - Steeringドキュメント
- `docs/completed/20260214_test_verification_automation.md` - この完了ドキュメント

### 変更

- `test_on_k6/package.json` - スクリプト追加
  - `build:verify`
  - `verify`
  - `ci:verify`
- `test_on_k6/.gitignore` - verify/_build/, verify/.mooncakes/を追加
- `test_on_k6/README.md` - 自動検証機能の説明追加

### 変更なし

- テストコード（src/test_all.mbt）
- ライブラリコード（プロジェクトルート）

## 実行結果

### 成功例

```bash
$ npm run ci:verify

> k6-moonbit-test@0.1.0 verify
> node verify/_build/js/release/build/k6-verify.js

Verifying test results for: k6 MoonBit Library Test

✓ iterations: 3 (expected: 3)
✓ http_reqs: 6 (expected: 6)
✓ checks_value: 1 (expected: 1)
✓ checks_passes: 9 (expected: 9)
✓ checks_fails: 0 (expected: 0)
✓ test_counter: 3 (expected: 3)
✓ test_requests: 6 (expected: 6)
✓ http_req_failed: 0 (expected: 0)

✅ All expectations passed!
```

### CI統合

```bash
npm run ci:verify
# ↓
# 1. npm run build           - テストコードビルド
# 2. npm run build:verify    - 検証スクリプトビルド
# 3. npm run test:json       - k6実行 + summary.json生成
# 4. npm run verify          - 自動検証
# ↓
# exit 0 (成功) または exit 1 (失敗)
```

## 実装時の課題と解決

### 課題1: MoonBitのJSON APIが不明確

**問題:** ドキュメントが不足しており、`@json.parse()`や`from_json()`の正しい使い方がわからない

**解決:**
- WebFetch失敗 → ユーザーがコードを修正
- `try?`とguard構文を使用
- `@json.from_json(json)`でデシリアライズ

### 課題2: ES module環境でrequireが使えない

**問題:** test_on_k6/package.jsonが`"type": "module"`のため、FFIの`require`が使えない

**解決:** verify/package.jsonに`"type": "commonjs"`を指定

### 課題3: summary.jsonの構造が想定と異なる

**問題:** `metrics.<name>.values.count`を想定していたが、実際は`metrics.<name>.count`

**解決:**
- summary.jsonの実際の構造を確認
- structを修正（`values`フィールドを削除）
- パス解析ロジックを修正

### 課題4: `type`フィールド名の衝突

**問題:** MoonBitでは`type`がキーワードのため、`type_`を使用。JSONとのマッピングが不明確

**解決:** expectations.jsonの`"type"`を`"type_"`に変更

## 今後の課題・改善点

### 機能拡張

- [ ] `min`/`max`型の検証（現在はexactのみ実装）
- [ ] 許容誤差の実装（浮動小数点の比較）
- [ ] 複数テストファイルのサポート
- [ ] HTMLレポート生成

### コード改善

- [ ] `@json.name("type")`アトリビュートの使用（`type_`回避）
- [ ] エラーメッセージの改善（詳細な差分表示）
- [ ] JSONPath::init()の正しい使い方を調査

### CI/CD統合

- [ ] GitHub Actions / GitLab CIでの実行例
- [ ] レポート履歴の保存
- [ ] 過去のテスト結果との比較

## ベストプラクティス

### 期待値の定義

1. **明確なメトリクス名**
   ```json
   "metric": "http_reqs"  // ✅ Good
   "metric": "test1"       // ❌ Bad
   ```

2. **正確なパス**
   ```json
   "path": "metrics.http_reqs.count"  // ✅ Good
   "path": "metrics.http_reqs.value"  // ❌ Bad (countを使う)
   ```

3. **適切な検証タイプ**
   - `exact`: カウント系（iterations, http_reqs）
   - `min`: レート系下限（将来）
   - `max`: レート系上限（将来）

### テスト設計

1. **予測可能なメトリクス**
   - VU=1, iterations=固定値 → カウントが予測可能
   - http_req_durationは検証対象外（環境依存）

2. **期待値の保守**
   - テスト変更時にexpectations.jsonも更新
   - コメントで期待値の根拠を記載

## 参考資料

- [Steeringドキュメント](../steering/20260214_test_verification_automation.md)
- [test_on_k6/README.md](../../test_on_k6/README.md)
- [MoonBit Core JSON Module](https://mooncakes.io/docs/moonbitlang/core/json)
- [k6 JSON Export](https://grafana.com/docs/k6/latest/results-output/end-of-test/json/)

## まとめ

test_on_k6の自動検証機能により、以下を達成しました：

✅ **MoonBitで型安全な検証スクリプトを実装**: derive(FromJson)を活用

✅ **k6レポートの自動検証**: 期待値との整合性を自動チェック

✅ **CI/CD対応**: `npm run ci:verify`ワンコマンドで全フロー実行、exit codeで成否判定

✅ **ドキュメント整備**: 実行手順、検証方法、トラブルシューティング完備

これにより、ライブラリの機能追加や修正時に、既存機能が壊れていないことを迅速かつ自動的に確認できるようになりました。
