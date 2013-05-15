package MT::LDAPLite::L10N::ja;

use strict;
use utf8;
use base 'MT::LDAPLite::L10N::en_us';
use vars qw( %Lexicon );

## The following is the translation table.

%Lexicon = (
    'Authenticates password with LDAP at first.' => 'はじめにLDAPでパスワードを認証します。',

    'LDAP password authentication is disabled with LDAPLiteDisabled environment variable. Check mt-config.cgi file.'
        => 'LDAPパスワード認証はLDAPLiteDisabled環境変数により無効にされています。mt-config.cgiファイルを確認してください。',

    'Host' => 'ホスト',
    'Hostname or IP address' => 'ホスト名またはIPアドレス',
    'Port' => 'ポート番号',
    'Default is 389.' => 'デフォルトは389です。',
    'Authentication' => '接続認証',
    'LDAP connection requires authentication to search user?'
        => 'ユーザー検索のためのLDAP接続に認証は必要ですか？',
    'None' => '不要',
    'Required' => '必要',
    'Root DN' => 'ルートDN',
    'Root Password' => 'ルートパスワード',
    'Users DN' => 'ユーザーのDN',
    'Connection DN' => '接続DN',
    'Connection DN Password' => '接続DNのパスワード',
    'User Login Name Attribute' => 'ユーザーのログイン名属性',
    'User Display Name Attribute' => 'ユーザーの表示名属性',
    'User Email Attribute' => 'ユーザーのメールアドレス属性',

    'Test' => 'テスト',
    'Testing' => 'テスト',
    'Test User Query' => 'ユーザーの検索',

    'LDAP connection succeeded.' => 'LDAP接続が成功しました。',
    'No user specified.' => 'ユーザーが指定されていません。',
    'Failure to search user.' => 'ユーザーの検索に失敗しました。',
    'The user found. Username: "[_1]", display name: "[_2]" and email: "[_3]".'
        => 'ユーザーが見つかりました。ユーザー名:"[_1]" 表示名:"[_2]" メールアドレス:"[_3]"',

);

1;

