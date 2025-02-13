#!/bin/bash

# install script
# install WordPress site
# install plugins

LOCAL='fr_FR'
URL='example.com'
TITLE='Example'
ADMIN_USER='admin'
ADMIN_PWD='admin'
ADMIN_EMAIL='infos@example.fr'

# setup config
DB_NAME=""
DB_USER=""
DB_PASSWORD=""
DB_HOST="localhost"
DB_PREFIX="$(tr -dc 'a-z0-9' < /dev/urandom | head -c 8)_"

if ! command -v wp &> /dev/null; then
    echo "WP-CLI not exist. Installation processing..."

    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

    chmod +x wp-cli.phar

    WP_CMD="php wp-cli.phar"
else
    WP_CMD="wp"
fi

# download WordPress
$WP_CMD core download --locale=$LOCAL


if [ -f wp-config.php ]; then
    echo "wp-config.php already exist. Remove file"
    rm wp-config.php
fi

$WP_CMD config create --dbname="$DB_NAME" --dbuser="$DB_USER" --dbpass="$DB_PASSWORD" --dbhost="$DB_HOST" --dbprefix="$DB_PREFIX"

if [ $? -eq 0 ]; then
    echo "wp-config.php generated with success"
else
    echo "Error for generated wp-config.php." >&2
    exit 1
fi

# add salt keys in wp-config.php
echo "Ajout des clés de sécurité..."
$WP_CMD config shuffle-salts

if [ -f wp-config.php ]; then
    echo "wp-config created with success"
else
    echo "Error : wp-config.php wasn't created." >&2
    exit 1
fi

$WP_CMD config set WP_ENV '"production"' --raw
$WP_CMD config set WP_DEBUG_LOG 'true' --raw
$WP_CMD config set WP_POST_REVISIONS '4' --raw


# install site
$WP_CMD core install --url=$URL --title=$TITLE --admin_user=$ADMIN_USER --admin_password=$ADMIN_PWD --admin_email=$ADMIN_EMAIL


# plugins
$WP_CMD plugin delete hello
# polylang
$WP_CMD plugin install polylang --activate
# better-wp-security
$WP_CMD plugin install better-wp-security --activate
# simple-page-ordering
$WP_CMD plugin install simple-page-ordering --activate
# wp-seopress
$WP_CMD plugin install wp-seopress --activate
# wp-optimize
$WP_CMD plugin install wp-optimize --activate
# redirection
$WP_CMD plugin install redirection --activate
# loco-translate
$WP_CMD plugin install loco-translate --activate
# performance-lab
$WP_CMD plugin install performance-lab --activate
# performant-translations
$WP_CMD plugin install performant-translations --activate
# webp-uploads
$WP_CMD plugin install webp-uploads --activate
# svg-support
$WP_CMD plugin install svg-support --activate

# git updater
$WP_CMD plugin install --activate https://github.com/afragen/git-updater/archive/master.zip


# install git plugins
$WP_CMD plugin install-git https://github.com/wpperformance/deaktiver.git --branch=main

$WP_CMD plugin activate deaktiver

$WP_CMD plugin install-git https://github.com/wpperformance/presswind-helpers --branch=main

$WP_CMD plugin activate presswind-helpers