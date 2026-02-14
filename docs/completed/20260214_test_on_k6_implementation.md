# 完了報告: test_on_k6ディレクトリの実装

作成日: 2026-02-14

## 実装内容

MoonBitで実装したk6ライブラリを、実際のk6ランタイム上で検証するテストスイート `test_on_k6/` を構築しました。

### 主要な成果物

1. **test_on_k6ディレクトリの構築**
   - vite + vite-plugin-moonbitを使用したビルド環境
   - 親モジュール（プロジェクトルート）への依存設定
   - k6で実行可能なJavaScriptへのトランスパイル

2. **包括的なテストスイート**
   - `src/test_all.mbt`: 4つのテストグループを含む統合テスト
     - Core API Tests (group, check, sleep)
     - HTTP Tests (quick_get, check_all)
     - Metrics Tests (Counter, カスタムメトリクス)
     - Lifecycle Tests (on_first_iteration, every_n_iterations)

3. **CI/CD対応**
   - `npm run ci`: ワンコマンドで全テスト実行
   - インストール → ビルド → テスト実行を自動化

4. **ドキュメント**
   - README.md: 実行手順、検証方法、トラブルシューティング
   - Steeringドキュメント: 実装方針の記録
   - この完了ドキュメント

## 技術的な決定事項

### 1. ディレクトリ構成

```
test_on_k6/
├── package.json          # vite, k6関連の依存
├── vite.config.js        # vite-plugin-moonbit設定
├── moon.mod.json         # 親モジュールへの依存
├── index.js              # エントリポイント（re-export）
├── src/
│   ├── moon.pkg          # パッケージ設定
│   └── test_all.mbt      # 統合テストスイート
└── README.md
```

### 2. 親モジュールへの依存

**moon.mod.json:**
```json
{
  "deps": {
    "ryota0624/k6": {
      "path": "../"
    }
  }
}
```

**moon.pkg:**
```moonbit
import {
  "ryota0624/k6" @k6,
  "mizchi/js/core" @core,
}
```

この設定により、プロジェクトルートのk6ライブラリをインポートしてテストできます。

### 3. テストファイルの統合

当初、test_core.mbt, test_http.mbt, test_metrics.mbtを個別に作成しましたが、MoonBitは同じパッケージ内の全.mbtファイルを1つのモジュールにコンパイルするため、関数名が衝突しました。

**解決策:** test_all.mbtに全テストを統合し、個別ファイルは削除しました。

### 4. 期待値駆動のテスト設計

各テストに期待される動作をコメントで明記：

```moonbit
// 期待される動作:
// - VU: 1
// - Iterations: 3
// - http_reqs: 6 (2 requests per iteration)
// - checks: 9 (3 checks per iteration)
// - test_counter: 3
// - test_requests: 6
```

k6レポートで期待値との整合性を確認します。

### 5. k6レポートを検証材料にする

負荷テストではなく、**機能の正確性**を検証します：

- VU数: 1（シンプル）
- Iterations: 3（少数）
- 実行時間: 数秒（迅速なフィードバック）

**検証項目:**
- `checks`: 100% (全て成功)
- `http_reqs`: 期待値と一致
- カスタムメトリクス: 期待値と一致
- `http_req_failed`: 0%

## 変更ファイル一覧

### 追加

- `test_on_k6/package.json`
- `test_on_k6/vite.config.js`
- `test_on_k6/moon.mod.json`
- `test_on_k6/index.js`
- `test_on_k6/src/moon.pkg`
- `test_on_k6/src/test_all.mbt`
- `test_on_k6/.gitignore`
- `test_on_k6/README.md`
- `docs/steering/20260214_test_on_k6_implementation.md`
- `docs/completed/20260214_test_on_k6_implementation.md` (このファイル)

### 変更

なし（既存のライブラリコードは変更していません）

## テスト結果

### 実行コマンド

```bash
cd test_on_k6
npm run ci
```

### 実行結果

```
✓ checks.........................: 100.00% ✓ 9 ✗ 0
✓ http_reqs......................: 6
✓ test_counter...................: 3
✓ test_requests..................: 6
✓ http_req_failed................: 0.00%
✓ iterations.....................: 3
```

### 期待値との整合性

| メトリクス | 期待値 | 実際の値 | 結果 |
|-----------|--------|---------|------|
| iterations | 3 | 3 | ✅ |
| http_reqs | 6 | 6 | ✅ |
| checks | 9 (100%) | 9/9 (100%) | ✅ |
| test_counter | 3 | 3 | ✅ |
| test_requests | 6 | 6 | ✅ |
| http_req_failed | 0% | 0% | ✅ |

**全ての期待値が満たされています。** MoonBitで書いたシナリオが意図通りに動作することを確認しました。

## テスト内容の詳細

### Test Group 1: Core API Tests
- `group()`: グループ化機能
- `quick_get()`: HTTPリクエスト
- `check_status_200()`: ステータスコード検証
- `sleep()`: 待機機能

### Test Group 2: HTTP Tests
- `quick_get()`: HTTPリクエスト（別エンドポイント）
- `check_all()`: 複数のcheck同時実行
- レスポンスボディの検証

### Test Group 3: Metrics Tests
- `Counter.increment()`: カウンタのインクリメント
- カスタムメトリクスの記録

### Test Group 4: Lifecycle Tests
- `on_first_iteration()`: 初回イテレーションでのみ実行
- `every_n_iterations(2)`: 2イテレーションごとに実行

## CI/CD統合

### ワンコマンド実行

```bash
npm run ci
```

このコマンドは以下を自動実行：
1. `npm install` - 依存関係インストール
2. `npm run build` - MoonBit → JS変換
3. `npm run test` - k6でテスト実行

### GitHub Actions / GitLab CI

```yaml
- name: Run k6 tests
  run: |
    cd test_on_k6
    npm run ci
```

## 今後の課題・改善点

### 追加テストの実装

現在のtest_all.mbtは基本的な機能をカバーしていますが、以下のモジュールは未テスト：

- [ ] k6/ws (WebSocket)
- [ ] k6/encoding (base64など)
- [ ] k6/crypto (ハッシュ、HMAC)
- [ ] k6/data (SharedArray)
- [ ] RequestBuilder の詳細機能（headers, tags, timeout等）
- [ ] Options の詳細設定（thresholds, scenarios等）

### JSON出力の活用

現在はテキスト形式のレポートを目視確認していますが、JSON出力を使えばプログラムで期待値との比較が可能：

```bash
npm run test:json
# summary.json を解析して自動判定
```

将来的には、期待値をファイルに記述し、自動的に比較するツールを作成できます。

### テストの並列実行

現在は1つのtest_all.mbtファイルですが、テスト数が増えた場合は複数のテストファイルに分割し、並列実行することで実行時間を短縮できます。

### パフォーマンスレグレッションテスト

現在は機能検証のみですが、パフォーマンスの劣化を検出するレグレッションテストも検討できます。

## 既知の制限事項

### 単一テストファイル制約

MoonBitは同じパッケージ内の全.mbtファイルを1つのモジュールにコンパイルするため、複数のテストファイルで同名の関数（options, setup, default, teardown）を定義できません。

**回避策:** 全テストを1つのtest_all.mbtファイルに統合。

### ネットワーク依存

テストはhttpbin.orgなど外部サービスに依存しているため、ネットワーク環境によっては失敗する可能性があります。

**将来の改善:** example-viteのようにdocker-composeでローカルサーバを起動し、そこに対してテストを実行する。

## example-viteとの差別化

| 観点 | test_on_k6 | example-vite |
|-----|-----------|--------------|
| **目的** | ライブラリの機能検証 | ユーザー向けサンプル |
| **対象** | 開発者（ライブラリメンテナ） | ユーザー（ライブラリ利用者） |
| **内容** | 機能網羅的なテスト | 実用的なシナリオ例 |
| **実行** | CI/CD自動テスト | マニュアル実行、学習用 |
| **VU数** | 1（シンプル） | 2〜10（実用的） |
| **期間** | 短時間（数秒） | 長時間（20秒〜） |
| **focus** | 期待値との整合性 | 負荷テスト、実用例 |

## 参考資料

- [Steeringドキュメント](../steering/20260214_test_on_k6_implementation.md)
- [test_on_k6/README.md](../../test_on_k6/README.md)
- [example-vite](../../example/example-vite/)
- [k6 Documentation](https://k6.io/docs/)
- [k6 Metrics](https://grafana.com/docs/k6/latest/using-k6/metrics/)

## まとめ

test_on_k6ディレクトリの実装により、以下を達成しました：

✅ **MoonBitで書いたシナリオの動作検証**: 実際のk6ランタイムで実行し、期待通りに動作することを確認

✅ **k6レポートを使った検証方法の確立**: 期待値をコメントで明記し、レポート出力で整合性を確認

✅ **CI/CD対応**: `npm run ci` ワンコマンドで全テスト実行可能

✅ **ドキュメント整備**: 実行手順、検証方法、トラブルシューティングを記載

これにより、ライブラリの機能追加や修正時に、既存機能が壊れていないことを迅速に確認できるようになりました。
