# チューニング

原則としてボトルネックを見つけてから以下を行う。（最終的には苦しまぎれに実施したい...

## MySQL の Index

```sh
# 作成
ALTER TABLE <table_name> ADD INDEX <index_name> (col1, col2, ...);

# 確認
SHOW INDEX FROM <table_name>;

# 削除
ALTER TABLE <table_name> DROP INDEX <index_name>;
```

## ミドルウェアのチューニング

nginx, php-fpm の設定について conf 参照

### Nginx <-> php-fpm をソケット通信化

apache + mod_php で高速化すると思ったがあまり速度が上がらなかったので、以下の方がいいかなと思った。

php-fpm.conf がリポジトリで管理されていれば、パスをそちらに向ける。

1. `$ mkdir /var/run/php-fpm` を作成すると同時に以下のファイルも設置する（再起動対策
1. `$ sudo echo 'd /var/run/php-fpm 0755 isucon isucon' > /etc/tmpfiles.d/php-fpm.conf`
1. nginx, php-fpm の実行ユーザを isucon で統一する(socket file が参照できない対策)
1. `php-fpm.conf` に以下を追加
    ```sh
    listen = /var/run/php-fpm/php-fpm.sock
    ```
1. `nginx.conf` に以下を追加
    ```sh
    fastcgi_pass unix:/var/run/php-fpm/php-fpm.sock;
    ```
1. nginx, php-fpm のリスタート

## PHP7 化

恐らく最初から php7.x が入っていると思うが、入っていなかったら以下を実行する。

予めbuild しておいたものを使う。使えなかった時用に、xbuild も準備しておく。（ビルドは30分程をとっておく
ビルド後は既存の php のバックアップを取って入れ替えて終わり。

7.2.0RC3 も試す価値あり。

1. `$ scp -C /path/to/php-7.1.9.tar.gz isucon:/path/to/php-7.1.9.tar.gz`
1. `$ tar -zxvf php-7.1.9.tar.gz`
1. `$ ln -fs ./php-7.1.9 ./php`

## Redis

### 導入

1. `$ sudo apt install redis-server`
1. `$ git clone https://github.com/phpredis/phpredis.git && cd phpredis`
1. `$ phpize && ./configure && make && make install`
1. `$ echo 'extension=redis.so' >> $(php -i | grep Loaded | head -1 | cut -d' ' -f5)`

### PHP <-> Redis をソケット通信化

1. `$ vim $(php -i | grep Loaded | head -1 | cut -d' ' -f5)`
    ```sh
    session.save_handler = redis
    session.save_path = "/tmp/redis.sock"
    ```
1. `$ vim /etc/redis/redis.conf`
    ```sh
    unixsocket /tmp/redis.sock
    unixsocketperm 755
    ```
