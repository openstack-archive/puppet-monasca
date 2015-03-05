# == Class: monasca::params
#
# This class is used to specify configuration parameters that are common
# across all monasca services.
#
# === Parameters:
class monasca::params(
    $api_db_user     = 'mon_api',
    $api_db_password = undef,
    $port            = '8082',
    $api_version     = 'v2.0',
    $region          = 'RegionOne',
    $admin_name      = 'monasca-admin',
    $agent_name      = 'monasca-agent',
    $user_name       = 'monasca-user',
    $auth_method     = 'token',
    $admin_password  = undef,
    $agent_password  = undef,
    $user_password   = undef,
    $sql_host        = undef,
    $sql_user        = undef,
    $sql_password    = undef,
) {
  validate_string($admin_password)
  validate_string($agent_password)

  if $::osfamily == 'Debian' {
    $agent_package = 'monasca-agent'
    $agent_service = 'monasca-agent'
  } elsif($::osfamily == 'RedHat') {
    $agent_package = false
    $agent_service = ''
  } else {
    fail("unsupported osfamily ${::osfamily}, currently Debian and Redhat are the only supported platforms")
  }
}
