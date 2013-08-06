package MT::LDAPLite::Util;

use strict;
use base 'Exporter';

our @EXPORT = qw(plugin connect_ldap search_an_user finish_ldap);

use Encode;
use Net::LDAP;
use MT::Author;

sub plugin {
    MT->component('LDAPLite');
}

sub system_config {
    my %config;
    plugin->load_config(\%config, 'system');
    \%config;
}

sub connect_ldap {
    my ( $args ) = @_;

    # Fill LDAP args from config if not passed
    my $config = system_config;
    for my $prop ( keys %$config ) {
        next unless $prop =~ /^ldap_/;
        $args->{$prop} = $config->{$prop}
            unless defined $args->{$prop};
    }

    # No LDAP host configured
    die plugin->translate('No LDAP server host defined.')
        unless length($args->{ldap_host});

    my $ldap = Net::LDAP->new(
        $args->{ldap_host},
        timeout => MT->instance->config('LDAPLiteTimeout') || 10,
        port => $args->{ldap_port} || 389
    ) or die ( $@  || plugin->translate('An error occured at LDAP connection.') );

    my $msg;
    if ( $args->{ldap_auth_type} eq 'none' ) {
        $msg = $ldap->bind;
    } else {
        $msg = $ldap->bind( $args->{ldap_root_dn}, password => $args->{ldap_root_password} );
    }

    die ( $msg->error || plugin->translate('An error occured at LDAP binding.') )
        if $msg->code;

    return $ldap;
}

sub search_an_user {
    my ( $ldap, $args, $user ) = @_;

    my %param = ( scope => 'sub' );
    $param{filter} = sprintf('(%s=%s)', $args->{ldap_user_name_attribute} || 'uid', $user);
    $param{base} = $args->{ldap_users_dn} if $args->{ldap_users_dn};

    my $msg = $ldap->search(%param);

    die ( $msg->error || plugin->translate('An error occured at LDAP search.') )
        if $msg->code;

    die ( plugin->translate('User named [_1] is not found in LDAP directory.', $user ) )
        if $msg->count < 1;
    die ( plugin->translate('Two or more than users found for [_1]. This is no use for a name.', $user) )
        if $msg->count > 1;

    my %entry;
    foreach my $e ( $msg->entries ) {

        my $attr;

        $entry{dn} = $e->dn;

        $attr = $args->{ldap_user_name_attribute} || 'uid';
        $entry{name} = $e->get_value($attr)
            or die plugin->translate('User entry of [_1] has no attribute for user name: ([_2])', $user, $attr);

        $attr = $args->{ldap_user_display_name_attribute} || 'cn';
        $entry{display_name} = $e->get_value($attr)
            or die plugin->translate('User entry of [_1] has no attribute for display name: ([_2])', $user, $attr);

        $attr = $args->{ldap_user_email_attribute} || 'email';
        $entry{email} = $e->get_value($attr)
            or die plugin->translate('User entry of [_1] has no attribute for email: ([_2])', $user, $attr);

        $entry{display_name} = Encode::decode_utf8($entry{display_name})
            unless Encode::is_utf8($entry{display_name});
    }

    return \%entry;
}

sub finish_ldap {
    my ( $ldap ) = @_;
    $ldap->unbind if $ldap;
}

sub cb_install_ldap_password_validator {
    my ( $cb, $app ) = @_;

    # hook to override MT::Author::is_valid_password as below
    1;
}

{

    # Install MT::Author::is_valid_password for LDAP.
    no warnings qw(redefine);
    my $original = \&MT::Author::is_valid_password;
    *MT::Author::is_valid_password = sub {
        my $author = shift;
        my ( $pass, $crypted, $error_ref ) = @_;
        my $app = MT->instance;

        # Skip LDAP authentication if disabled
        return $original->($author, @_)
            if MT->instance->config('LDAPLiteDisabled');

        # Connect and search the user
        my $args = {};
        my ( $ldap, $dn, $result_code );

        # Connect
        {
            local $@;
            eval {
                $ldap = connect_ldap($args);
            };
            if ( $@ || !$ldap ) {
                finish_ldap($ldap);
                return $original->($author, @_);
            }
        }

        # Search and get DN
        {
            local $@;
            eval {
                my $entry = search_an_user($ldap, $args, $author->name);
                $dn = $entry->{dn};
            };
            if ( $@ || !$dn ) {
                finish_ldap($ldap);
                $app->log(
                    plugin->translate(
                        "User '[_1]' (ID:[_2]) is not found in LDAP directory. Tring internal password.",
                        $author->name, $author->id
                    ),
                    level    => MT::Log::INFO(),
                    class    => 'author',
                    category => 'ldap_lite',
                );
                return $original->($author, @_);
            }

        }

        # Bind with the DN
        my $msg = $ldap->bind($dn, password => $pass || '');
        if ( $result_code = $msg->code ) {
            $app->log(
                plugin->translate(
                    "User '[_1]' (ID:[_2]) faild to log in with LDAP password. Tring internal password.",
                    $author->name, $author->id
                ),
                level    => MT::Log::INFO(),
                class    => 'author',
                category => 'ldap_lite',
            );
        }

        # Finish
        finish_ldap($ldap);

        # Logged in successfully
        return 1 unless $result_code;

        # Delegate to original is_valid_password
        $original->($author, @_);
    };
}

1;
