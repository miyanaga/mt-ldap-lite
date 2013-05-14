package MT::LDAPLite::CMS;

use strict;

use Net::LDAP;
use Digest::MD5;
use MT::LDAPLite::Util;

sub system_config {
    my ( $app, $param, $scope ) = @_;
    plugin->load_tmpl('system_config.tmpl', $param);
}

sub method_ldap_lite_query {
    my $app = shift;
    my %hash = $app->param_hash;

    # Call ldap_lite_query
    local $@;
    my $result;
    eval {
        $result = ldap_lite_query(\%hash);
    };

    # Handle if error
    return $app->json_error($@)
        if $@; # Exception
    return $app->json_error($result->{error})
        if defined $result->{error}; # Error

    # Result
    $app->json_result($result->{result} || {});
}

sub method_ldap_lite_test_connection {
    my $app = shift;
    my %hash = $app->param_hash;

    local $@;
    eval {
        my $ldap = connect_ldap(\%hash);
        finish_ldap($ldap);
    };
    return $app->json_error($@) if $@;

    $app->json_result( { message => plugin->translate('LDAP connection succeeded.') } );
}

sub method_ldap_lite_test_query_user {
    my $app = shift;
    my %hash = $app->param_hash;
    my $username = delete $hash{test_query_user};

    return $app->json_error('No user specified.') unless $username;

    local $@;
    my $entry;
    eval {
        my $ldap = connect_ldap(\%hash);
        $entry = search_an_user($ldap, \%hash, $username);
        finish_ldap($ldap);
    };
    return $app->json_error($@) if $@;

    $entry->{message} = plugin->translate(
        'The user found. Username: "[_1]", display name: "[_2]" and email: "[_3]".',
        $entry->{name}, $entry->{display_name}, $entry->{email}
    );

    my $token = Digest::MD5::md5_hex(rand());
    my $token_length = MT->instance->config('LDAPLiteNewPasswordLength') || 10;
    $entry->{random_token} = substr($token, 0, $token_length);

    $app->json_result( $entry );
}

sub method_ldap_lite_search_user {
    my $app = shift;
    my %hash = $app->param_hash;
    my $username = delete $hash{test_query_user};


}

sub cb_template_param_edit_author {
    my ( $cb, $app, $param, $tmpl ) = @_;

    # Show username as editable.
    $param->{auth_mode_mt} = 1;

    # Show external id.
    $param->{external_id} = ' ';
    $param->{show_external_id} = 1;

    # Insert jQuery script.
    my $js_node = $tmpl->createElement('setvarblock', {
        append => 1,
        name => 'jq_js_include',
    });
    my $js_tmpl = plugin->load_tmpl('edit_author_script.tmpl');
    print STDERR $js_tmpl->text;
    $js_node->innerHTML($js_tmpl->text);

    my $includes = $tmpl->getElementsByTagName('include');
    foreach my $include ( @$includes ) {
        if ( $include->attributes->{name} && $include->attributes->{name} =~ /footer\.tmpl/ ) {
            $tmpl->insertBefore($js_node, $include);
            last;
        }
    }

    1;
}

1;
