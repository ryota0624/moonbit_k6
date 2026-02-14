# Goal
https://github.com/DefinitelyTyped/DefinitelyTyped/tree/master/types/k6 を参考にしてk6のmoonbitファサードを作成する

# TODO

- [ ] k6のAPIをmoonbitのffiで網羅する
  - ディレクトリ1つづつ作業したいので、まずは作業予定のディレクトリをREADMEに記載する
  - JavaScriptのFFIはhttps://github.com/mizchi/js.mbtを利用する
  - exampleディレクトリにk6のexampleをmoonbitで動かすコードを記載する
    - exampleはdocker-composeで動かせるようにする
      - 負荷をかけられるサーバとk6が動く環境を用意する
    - k6用のmoonbitファイルのバンドルにはhttps://github.com/mizchi/vite-plugin-moonbitを使う
    - バンドル後のコードはk6のルールにしたがってexport defaultやexport optionsがある状態になる
- [ ] k6のAPIをラップして、より使いやすいAPIを提供する
  - ffiが網羅できたら、ラップしてより使いやすいAPIを提供する
