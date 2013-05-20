# MTLDAPLite

Movable Type plugin to enable LDAP password login.

The user password at login, tring to LDAP bind at first. If the user not found in directory, or the password is not correct, seocondly trying to internal password.

# Setting

## LDAP connection and attributes

Set connection at system scoped plugin's settings.

## Environment Variables

* LDAPLiteDisabled: Set to 0 to disabled LDAP authentication.
* LDAPLiteRootPassword: Root DN password(optional)

# License

This program is distributed under the terms of the GNU General Public License, version 2.
