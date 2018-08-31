# 開発環境

これは雛形とし、本番ソースコードに合わせて調整していきましょう

## 前提

* Docker, Composer, PHP7.1は全員のPCにインストール済みとする

## Docker開発環境

### 準備

* `webapp/php` ディレクトリにPHPソースコードを配置してください
* `webapp/static` ディレクトリに静的ファイルを配置してください
* `initdb.d/` ディレクトリにSQLファイルを配置してください。コンテナ起動時に自動的に指定データベースにインポートされます。
* `docker-compose-yml` ファイルの以下をソースコードに合わせて修正してください

```sh
      MYSQL_DATABASE: isucon
      MYSQL_USER: isucon
      MYSQL_PASSWORD: password
```

### 構築

```sh
# コンテナをバックグラウンドで起動
$ docker-compose up -d

# ログを表示
$ docker-compose logs -f

# キャッシュを使わずにビルドする。Dockerfileを変更した場合は --no-cache を付けるとミスがないです。
$ docker-compose build --no-cache
```

### PHPプロファイラ XDebug

ref: [【パフォーマンス】XDebugとqcachegrindによるPHPアプリのプロファイリング【改善】 \- ハウテレビジョン開発者ブログ](http://blog.howtelevision.co.jp/entry/2014/11/14/192350)

* Docker開発環境では `/tmp/xdebug` ディレクトリにXDebugの解析ファイルが出力されます。そのファイルをqcachegrindで読み込んで分析してください。

#### 事前準備

homebrewで以下をインストールします。

```sh
$ brew install graphviz qt qcachegrind
```

#### 起動

Mac のコマンドラインから以下を実行すると起動します。

```sh
$ qcachegrind
```

## ビルトインサーバー

* Docker開発環境が使えなかった場合は、ビルトインサーバーを使いましょう
* 静的ファイル(staticディレクトリ以下の中身)は、phpディレクトリ以下にコピーすれば、プログラムの改修なしに利用できます。

```sh
# php -S ホスト名:ポート番号 -t ドキュメントルートのパス
$ php -S localhost:8080 -t webapp/php
```
