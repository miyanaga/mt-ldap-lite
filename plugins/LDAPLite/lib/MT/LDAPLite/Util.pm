package MT::LDAPLite::Util;

use strict;
use base 'Exporter';

our @EXPORT = qw(plugin connect_ldap search_an_user finish_ldap);

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

sub ldap_lite_root_bind {
    my $args = shift;

}

sub connect_ldap {
    my $args;
    if ( ref $_[0] eq 'HASH' ) {
        $args = $_[0];
    } else {
        my %hash = @_;
        $args = \%hash;
    }

    my $config = system_config;

    # Fill ldap args if not passed
    for my $prop ( keys %$config ) {
        next unless $prop =~ /^ldap_/;
        $args->{$prop} = $config->{$prop}
            unless defined $args->{$prop};
    }

    my $ldap = Net::LDAP->new( $args->{ldap_host},
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

    die ( plugin->translate('User named [_1] is not found.', $user ) )
        if $msg->count < 1;
    die ( plugin->translate('Two or more than users found.') )
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
    }

    return \%entry;
}

sub finish_ldap {
    my ( $ldap ) = @_;
    $ldap->unbind if $ldap;
}

sub cb_install_ldap_password_validator {
    my ( $cb, $app ) = @_;

    # hook to override is_valid_password

    1;
}

{

    # Install is_valid_password for LDAP.
    no warnings qw(redefine);
    my $original = \&MT::Author::is_valid_password;
    *MT::Author::is_valid_password = sub {
        my $author = shift;
        my ( $pass, $crypted, $error_ref ) = @_;

        my $args = {};
        my $ldap = connect_ldap($args);
        my $entry = search_an_user($ldap, $args, $author->name);

        my $dn = $entry->{dn};
        print STDERR $dn, "\n\n";

        my $msg = $ldap->bind($dn, password => $pass);
        return 1 unless $msg->code;

        # TODO: Log to fail.

        $original->($author, @_);
    };
}

1;
