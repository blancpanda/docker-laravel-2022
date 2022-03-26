# Laravel 用 Docker 構成 2022年版

- Jetstream (inertia) を使う前提

## コンテナの起動/停止

### 初回

```sh
docker compose --profile extra up -d --build
docker compose --profile extra down
```

### 2回目以降

```sh
docker compose up -d
docker compose down
```

### プロファイル extra について

node コンテナを起動しておくと watch で待機するようになるので、ファイルの変更にあわせて自動でコンパイルが行われる
普段は任意のタイミングで npm run dev を実行したいので、別プロファイルにして node コンテナのみ起動しないようにしている

### コマンドのショートカット

コマンドが長いので bin配下にショートカットのためのスクリプトを用意してある
実行できるようにパーミッションを変更する

```sh
chmod u+x bin/*
```

以下のような使い方ができる

```sh
bin/npm run dev
```

## Laravel のインストール

app コンテナに入り、Laravel と Jetstream をインストール

```sh
docker compose exec app bash
composer create-project --prefer-dist "laravel/laravel=9.*" .
php artisan storage:link
chmod -R 777 storage bootstrap/cache
composer require laravel/jetstream
php artisan jetstream:install inertia
exit
```

node コンテナで リソースのコンパイル

```sh
bin/npm install
bin/npm run dev
```

.env を編集してデータベースの接続先を設定

```text:laravel/.env
# :
DB_CONNECTION=mysql
DB_HOST=db
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=phper
DB_PASSWORD=secret
# :
```

app コンテナでマイグレーション

```sh
bin/artisan migrate
exit
```

## VSCode の設定ファイル

- XDebug を使ったデバッグ実行のための構成ファイル .vscode/launch.json を用意してある
- Vue 用の拡張 Vetur を使う関係で、Laravel の階層が異なるので、 .vetur.config.js で指定している
- Vetur はプロジェクトルートで jsconfig.json か tsconfig.json を探すので、Laravel インストール後に laravel ディレクトリ直下に作成する

```json:laravel/jsconfig.json
{
    "compilerOptions": {
        "baseUrl": ".",
        "paths": {
            "@/*": ["resources/js/*"]
        }
    },
    "exclude": ["node_modules", "public"]
}
```

## [テーブル定義書](laravel/database/README.md)の生成

db コンテナ内で mysqldump を使って出力したテーブル定義の xml に xslt をあててマークダウンのテーブル定義書を生成できるようにしている

### mysqldumpでテーブル定義のxmlを出力

```sh
docker compose exec db sh
mysqldump --no-data --xml -u root -p laravel > ./work/laravel.xml
Enter password: secret
exit
```

コメントを出力するようにしているので、日本語名や説明を設定しておくとよい。

### xsltをあててマークダウンに変換

```sh
xsltproc -o laravel/database/README.md tables-mdstyle.xsl db-work/laravel.xml
```

## Laravel をこの Docker 構成ごと git 管理下においた場合の clone からの再構築

初回起動時は extra プロファイルをつけて up
※ [repository], [project-dir] は各環境に置き換える

```sh
git clone [repository]
cd [project-dir]
chmod u+x bin/*
docker compose --profile extra up -d --build
docker compose exec app bash
composer install
cp .env.example .env
php artisan key:generate
php artisan storage:link
chmod -R 777 storage bootstrap/cache
exit
bin/npm install
bin/npm run dev
bin/artisan migrate
```

初回起動時は extra プロファイルをつけて down

```sh
docker compose --profile extra down
```
