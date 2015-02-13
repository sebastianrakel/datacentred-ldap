# == Class: ldap::params
#
# Default paramaters for different operating systems, etc
#
class ldap::params {

  $client_package_ensure   = 'present'
  $client_config_template  = 'ldap/ldap.conf.erb'

  $client_ssl             = false
  $client_ssl_cacert      = undef
  $client_ssl_cacertdir   = undef
  $client_ssl_cert        = undef
  $client_ssl_key         = undef
  $client_ssl_reqcert     = 'demand'

  $client_sizelimit = undef
  $client_timelimit = 15

  $server_package_ensure      = 'present'
  $server_service_enable      = true
  $server_service_ensure      = 'running'
  $server_service_manage      = true
  $server_config_template     = 'ldap/slapd.conf.erb'
  $server_backend             = 'bdb'
  $server_db_config_file      = "${server_directory}/DB_CONFIG"
  $server_db_config_template  = 'ldap/DB_CONFIG.erb'

  $server_log_level = 'none'

  $server_ssl        = false
  $server_ssl_cacert = undef
  $server_ssl_cert   = undef
  $server_ssl_key    = undef
  $server_ssl_verify_client = undef

  $config           = false
  $monitor          = false

  $server_access = [
    # to what
    { 'attrs=userPassword,shadowLastChange' => [
      # by who => access
      { 'self' => '@@writeable_on_sync_provider_only@@' },
      { 'anonymous' => 'auth' },
    ] },
    { 'attrs=objectClass,cn,uid,uidNumber,gidNumber,gecos,homeDirectory,loginShell,member,memberUid,entry' => [
      { '*' => 'read' },
    ] },
  ]

  $server_bind_anon = false
  $server_bind_v2   = true

  $server_overlays  = [ ]
  $server_modules   = [ ]
  $server_schemas   = [ 'core', 'cosine', 'nis', 'inetorgperson' ]
  $server_extra_schemas = [ ]
  $server_schema_source_directory = 'puppet:///files/ldap/schema'
  $server_indexes   = [ 'objectclass  eq',
                        'entryCSN     eq',
                        'entryUUID    eq',
                        'uidNumber    eq',
                        'gidNumber    eq',
                        'cn           pres,sub,eq',
                        'sn           pres,sub,eq',
                        'uid          pres,sub,eq',
                        'displayName  pres,sub,eq' ]

  $gem_ensure       = 'present'

  case $::osfamily {
    'Debian': {
      $ldap_config_directory   = '/etc/ldap'
      $os_config_directory     = '/etc/default'

      $client_package_name     = 'libldap-2.4-2'
      $client_config_file      = "${ldap_config_directory}/ldap.conf"

      $pidfile                 = '/var/run/slapd/slapd.pid'
      $argsfile                = '/var/run/slapd/slapd.args'
      $ldapowner               = 'openldap'
      $ldapgroup               = 'openldap'

      $server_package_name     = 'slapd'
      $server_service_name     = 'slapd'
      $server_config_file      = "${ldap_config_directory}/slapd.conf"
      $server_default_file     = "${os_config_directory}/slapd"
      $server_default_template = 'ldap/debian/defaults.erb'
      $server_directory        = '/var/lib/ldap'
      $gem_name                = 'net-ldap'
    }
    'OpenBSD': {
      $ldap_config_directory   = '/etc/openldap'
      $os_config_directory     = undef

      $client_package_name     = 'openldap-client'
      $client_config_file      = "${ldap_config_directory}/ldap.conf"

      $pidfile                 = '/var/run/openldap/slapd.pid'
      $argsfile                = '/var/run/openldap/slapd.args'
      $ldapowner               = '_openldap'
      $ldapgroup               = '_openldap'

      $server_package_name     = 'openldap-server'
      $server_service_name     = 'slapd'
      $server_config_file      = "${ldap_config_directory}/slapd.conf"
      $server_default_file     = undef
      $server_default_template = undef
      $server_directory        = '/var/openldap-data'
      $gem_name                = 'net-ldap'
    }
    'RedHat': {
      $ldap_config_directory   = '/etc/openldap'
      $os_config_directory     = '/etc/sysconfig'

      $client_package_name     = 'openldap-clients'
      $client_config_file      = "${ldap_config_directory}/ldap.conf"
      $ldapowner               = 'ldap'
      $ldapgroup               = 'ldap'

      $pidfile                 = '/var/run/openldap/slapd.pid'
      $argsfile                = '/var/run/openldap/slapd.args'

      $server_package_name     = 'openldap-servers'
      $server_service_name     = 'slapd'
      $server_config_file      = "${ldap_config_directory}/slapd.conf"
      $server_default_file     = "${os_config_directory}/ldap"
      $server_default_template = 'ldap/redhat/sysconfig.erb'
      $server_directory        = '/var/lib/ldap'
      $gem_name                = 'net-ldap'
    }
    default: {
      fail("${::module_name} is not supported on ${::osfamily}.")
    }
  }

  $server_schema_directory    = "${ldap_config_directory}/schema"
  $server_kerberos            = false
  $server_krb5_keytab         = "${ldap_config_directory}/ldap.keytab"
  $server_krb5_ticket_cache   = "${ldap_config_directory}/ldap.krb5cc"
}
