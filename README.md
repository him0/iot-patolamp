# IoT Patolamp

Raspberry Pi でパトランプをパカパカする。

## setup

```
$ rbenv install
$ bundle install --path=vendor/bundle
```

.env をどうにか読み込ませてください（TODO: もう少しスマートにする）

certs のディレクトリに IoT Core の設定時に生成される認証ファイルを入れる

## start server

Raspberry Pi で実行するサーバ、root なしで GPIO が制御できます。

```
$ bundle exec patolamp.rb
```

## start client

パトランプの状態を変えるクライアント

```
$ bundle exec client.rb
```

typo true or false 
