# First step

*推測するな計測せよ*

予選を突破するための初動を固める

## レギュレーションの熟読

以下を熟読
特に**スコアの計算方法**、**Success/Fail の判定条件**、**許可されること・されないこと**に気をつける

- 事前告知される内容
- 当日公開される内容

## sshログイン

ssh 周りでつんだら[ココ](http://iwamocchan11.hatenadiary.jp/entry/2015/10/25/124048)

1. ssh_config の host を設定する
1. 各々のPCに設定を追加する
1. `/home/isucon/.ssh/authorized_key` に各自の公開鍵を追加

## システムを把握する

いきなりチューニングをしない、確認が大事

### ブラウザでアクセス

- アプリケーションを把握
  - ログインできない場合はハックして改変
- 簡易ER図の作成
  - リレーション、CRUD状態をホワイトボードに書き出す

### サーバ上で以下を実行

#### mysqldump

シュッととって開発環境に入れてコミットする

`/home/isucon` で実行する

```sh
# 指定データベースのテーブルとデータを取得
$ mysqldump -uroot -h localhost #{database name} -n > dump.sql

# ローカルにコピー
$ scp -rpC isucon:/home/isucon/dump.sql initdb.d/
```

#### マシンスペックのチェック

- `$ lscpu`
  - cpu の使用状況
  - `$ /proc/cpuinfo` で詳細
- `$ /proc/meminfo`
  - メモリの使用状況を確認

#### プロセスのチェック

何のデーモンやミドルウェアで構成されているかを把握

- `$ pstree`
  - プロセスの確認（簡易
- `$ ps auxwwf`
  - プロセスの確認（詳細
- `$ lsof`
  - ファイルを実行しているプロセスを知りたい場合
- `$ env`
  - 環境変数を確認しておく
  - 本番環境で実行されているか

#### サービス名の確認

- [<app-name>](https://github.com/hypermkt/ISUCON7/blob/master/scripts/restart.sh)を変更する

## Git で管理

1. `/home/isucon/webapp/php` を gitで管理する
    - php ディレクトリのコピーを作成しておく
    - ghe で管理できるようにする
1. ソースをローカルに持ってくる
    ```sh
    $ scp -rpC isucon:/home/isucon/webapp/php webapp/
    $ scp -rpC isucon:/home/isucon/webapp/static webapp/
    ```
1. `/etc` 以下も git で管理する
    - init, add, first commit までやっておく

## 初回のベンチを実行する

初回のベンチを実行し、スコアを取得する。このスコアを基準に改善していく。

## 必要なツールのインストール

調査に必須のツールをまとめてインストールする

`$ sudo apt-get update -qq && sudo apt-get install -qq htop unzip percona-toolkit php-xdebug`

## PHPに切り替えてベンチマーク

### 準備

- `$ bash <(curl -Ss https://my-netdata.io/kickstart-static64.sh)`
  - netdata の画面は常に表示しておくと良い
  - port: 19999
- systemctl 使ってPHP切り替え

### 実行

- `$ htop`
  - プロセスチェック
- `$ journalctl -f` してからベンチを実行する
  - 問題が起きないか確認する

## ボトルネックを見つける

### alp

nginx のログからどのエンドポイントがボトルネックかを測定する

1. nginx のログの設定を行う
1. `$ wget https://github.com/tkuchiki/alp/releases/download/v0.3.1/alp_linux_amd64.zip`
1. `$ sudo mv alp /usr/local/bin`
1. `$ sudo alp --sum -r -f /var/log/nginx/access.log --aggregates='/keyword/.*'`
1. 結果を gist に貼って共有する

### Percona Toolkit

slow query の解析を行う
ツールの実行は3分くらいかかる

1. `$ sudo pt-query-digest --limit 10 /var/log/mysql/slow.log`
1. 結果を gist に貼って共有する

### XDebug

php.ini は `$ php -i | grep Loaded | head -1 | cut -d' ' -f5` で出せる

1. `xdebug.so` が追加されたphp.iniファイルに以下を追記
    ```sh
    xdebug.profiler_enable = 1
    xdebug.profiler_output_dir = /tmp/xdebug
    xdebug.profiler_output_name = callgrind.%R.%t
    ```
    - もしファイル出力を有効にした場合は、ISUCON終了前に出力を停止すること
1. アプリケーションを操作する度に`/tmp/xdebug`にファイルが出力される。そのファイルを手元に持ってきて、`qcachegrind`で解析する。

## チューニング

*一改善につき一ベンチ*

ここまでの調査を経て、ボトルネックの調整を行う。一時間以内に着手できれば良さそう。
