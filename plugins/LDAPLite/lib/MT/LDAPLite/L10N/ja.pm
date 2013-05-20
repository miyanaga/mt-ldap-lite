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

    'No LDAP server host defined.' => 'LDAPサーバーが設定されていません。',
    'LDAP connection succeeded.' => 'LDAP接続が成功しました。',
    'No user specified.' => 'ユーザーが指定されていません。',
    'Failure to search user.' => 'ユーザーの検索に失敗しました。',
    'The user found. Username: "[_1]", display name: "[_2]" and email: "[_3]".'
        => 'ユーザーが見つかりました。ユーザー名:"[_1]" 表示名:"[_2]" メールアドレス:"[_3]"',

    "User '[_1]' (ID:[_2]) is not found in LDAP directory. Tring internal password."
        => "ユーザー '[_1]' (ID:[_2]) はLDAPディレクトリに見つかりません。内部パスワードを試行します。",
    "User '[_1]' (ID:[_2]) faild to log in with LDAP password. Tring internal password."
        => "ユーザー '[_1]' (ID:[_2]) はLDAPログインに失敗しました。内部パスワードを試行します。",

    'An error occured at LDAP connection.' => 'LDAP接続でエラーが発生しました。',
    'An error occured at LDAP search.' => 'LDAP検索でエラーが発生しました。',
    'User named [_1] is not found in LDAP directory.'
        => 'ユーザー [_1] はLDAPディレクトリに存在しません',
    'Two or more than users found for [_1]. This is no use for a name.'
        => '[_1] については2件以上の該当結果があります。ログイン名には使用できません。',
    'User entry of [_1] has no attribute for user name: ([_2])'
        => '[_1] に対するエントリーはログイン名のための属性 [_2] を持っていません。',
    'User entry of [_1] has no attribute for display name: ([_2])'
        => '[_1] に対するエントリーは表示名のための属性 [_2] を持っていません。',
    'User entry of [_1] has no attribute for email: ([_2])'
        => '[_1] に対するエントリーはメールアドレスのための属性 [_2] を持っていません。',
);

1;

