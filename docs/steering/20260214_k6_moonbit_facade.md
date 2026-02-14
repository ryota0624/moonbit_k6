# Steering: k6 MoonBitファサードの実装

## 目的・背景

k6は負荷テストツールであり、JavaScriptでテストシナリオを記述する。MoonBitでk6のAPIを利用可能にすることで、型安全で保守性の高い負荷テストコードを記述できるようにする。

DefinitelyTypedに存在するk6の型定義（TypeScript）を参考に、MoonBitでのFFIバインディングを作成し、k6の全APIを利用可能にする。

## ゴール

1. k6の全APIをMoonBitから呼び出せるようにする
   - DefinitelyTypedの型定義を参照し、網羅的にFFIバインディングを実装
   - JavaScriptのFFIは`mizchi/js.mbt`を利用

2. MoonBitで記述したk6スクリプトを実行可能にする
   - `vite-plugin-moonbit`でバンドル
   - k6のルールに従った`export default`と`export options`を含むJavaScriptを生成

3. 動作確認可能なexampleを提供
   - docker-composeで負荷テスト環境を構築
   - サンプルサーバとk6実行環境を含む

4. より使いやすいラッパーAPIの提供
   - 基本的なFFIバインディングをラップし、MoonBit流の型安全なAPIを提供

## アプローチ

### フェーズ1: 型定義の取り込みと調査（タスク#2, #3）
- `example/package.json`を作成し、`@types/k6`をdevDependencyに追加
- DefinitelyTypedのk6型定義を調査
- 作業対象のディレクトリ/モジュールをリストアップ
- README.mdとTodo.mdに作業計画を記載

### フェーズ2: FFIバインディングの実装（タスク#4）
- `mizchi/js.mbt`をプロジェクトに統合
- ディレクトリ単位でFFIバインディングを実装
- 各ディレクトリに対応するMoonBitパッケージを作成

### フェーズ3: exampleの実装（タスク#5）
- `example/`ディレクトリに以下を作成:
  - MoonBitで記述したk6スクリプト
  - `vite-plugin-moonbit`を使ったビルド設定
  - docker-compose.yml（負荷テスト対象サーバ + k6実行環境）
  - 実行手順のドキュメント

### フェーズ4: ラッパーAPIの設計・実装
- FFIバインディングを基に、より使いやすいAPIを設計
- MoonBitの型システムを活用した安全なAPI

## スコープ

### 含む
- k6の全APIに対するFFIバインディング
- `mizchi/js.mbt`の統合
- `vite-plugin-moonbit`を使ったバンドル設定
- docker-composeによるexample実行環境
- 基本的なラッパーAPI

### 含まない
- k6本体の改造や拡張
- k6以外の負荷テストツールとの統合
- プロダクション環境でのk6実行インフラ
- 高度な負荷テストシナリオのテンプレート集（基本的なexampleのみ）

## 影響範囲

### 新規作成ファイル
- `docs/steering/20260214_k6_moonbit_facade.md`（このファイル）
- `example/package.json` - k6型定義のインポート用
- `example/docker-compose.yml` - 実行環境
- `example/src/*.mbt` - サンプルスクリプト
- `example/vite.config.js` - バンドル設定
- k6の各モジュールに対応するMoonBitパッケージ（`src/http/`, `src/metrics/`など）

### 変更ファイル
- `moon.mod.json` - 依存関係の追加（js.mbt等）
- `README.mbt.md` - プロジェクト概要、使用方法の記載
- `Todo.md` - 作業進捗の更新
- `.gitignore` - node_modules等の追加

### 依存関係
- `mizchi/js.mbt` - JavaScript FFI
- `@types/k6` - 型定義の参照用（devDependency）
- `vite-plugin-moonbit` - バンドル用

## リスク・課題

1. **k6 APIの網羅性**: k6のAPIは広範囲。段階的に実装を進める必要がある
2. **FFIの制約**: MoonBitのJavaScript FFIの制約により、一部のAPIが実装困難な可能性
3. **バンドル出力**: `export default`や`export options`のフォーマットが正しく出力されるか検証が必要
4. **実行環境**: docker-composeでのk6実行がスムーズに動作するか確認が必要

## 次のステップ

1. タスク#1完了後、タスク#2（k6型定義の取り込み）を開始
2. タスク#3でDefinitelyTypedの構造を調査し、実装計画を具体化
3. 以降、タスク#4, #5と順次進める
