package MT::LDAPLite::CMS;

use strict;

use Net::LDAP;
use Digest::MD5;
use MT::LDAPLite::Util;

sub system_config {
    my ( $app, $param, $scope ) = @_;

    $param->{ldap_lite_disabled} = 1
        if MT->instance->config('LDAPLiteDisabled');

    # Returns system_config.tmpl
    plugin->load_tmpl('system_config.tmpl', $param);
}

sub method_ldap_lite_test_connection {
    my $app = shift;
    my %hash = $app->param_hash;

    # Test to connect to LDAP
    local $@;
    eval {
        my $ldap = connect_ldap(\%hash);
        finish_ldap($ldap);
    };

    # Handle if error occured
    return $app->json_error($@) if $@;

    # Result message
    $app->json_result( { message => plugin->translate('LDAP connection succeeded.') } );
}

sub method_ldap_lite_test_query_user {
    my $app = shift;
    my %hash = $app->param_hash;
    my $username = delete $hash{test_query_user};

    return $app->json_error('No user specified.') unless $username;

    # Test to connect and search user
    local $@;
    my $entry;
    eval {
        my $ldap = connect_ldap(\%hash);
        $entry = search_an_user($ldap, \%hash, $username);
        finish_ldap($ldap);
    };

    # Handle if error occured
    return $app->json_error($@) if $@;
    return $app->json_error(plugin->translate('Failure to search user.'))
        unless $entry;

    # Message
    $entry->{message} = plugin->translate(
        'The user found. Username: "[_1]", display name: "[_2]" and email: "[_3]".',
        $entry->{name} || '', $entry->{display_name} || '', $entry->{email} || ''
    );

    # Random token for new password
    srand(time);
    my $token = Digest::MD5::md5_hex(rand());
    my $token_length = MT->instance->config('LDAPLiteNewPasswordLength');
    $token_length = length($token) if $token_length > length($token);
    $entry->{random_token} = substr($token, 0, $token_length)
        if $token_length;

    # Return result
    $app->json_result( $entry );
}

sub cb_template_param_edit_author {
    my ( $cb, $app, $param, $tmpl ) = @_;

    # Show username as editable.
    $param->{auth_mode_mt} = 1;

    # Show external id.
    $param->{external_id} = ' ';
    $param->{show_external_id} = 1;

    # Insert jQuery script before footer
    my $js_node = $tmpl->createElement('setvarblock', {
        append => 1,
        name => 'jq_js_include',
    });
    my $js_tmpl = plugin->load_tmpl('edit_author_script.tmpl');
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
