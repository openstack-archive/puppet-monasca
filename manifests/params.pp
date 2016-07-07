# == Class: monasca::params
#
# This class is used to specify configuration parameters that are common
# across all monasca services.
#
# === Parameters:
#
# [*api_db_user*]
#   name of the monasca api user for the database
#
# [*api_db_password*]
#   password for the monasca api database user
#
# [*port*]
#   port to run monasca api server on
#
# [*api_version*]
#   version of the monasca api to configure
#
# [*region*]
#   default openstack region for this monasca api instance
#
# [*admin_name*]
#   name of the monasca admin user
#
# [*agent_name*]
#   name of the monasca agent user
#
# [*user_name*]
#   name of the default monasca user
#
# [*auth_method*]
#   keystone auth method, token or password
#
# [*admin_password*]
#   password for the monasca admin user
#
# [*admin_project_name*]
#   project name for the monasca admin user
#
# [*agent_password*]
#   password for the monasca agent user
#
# [*user_password*]
#   password for the monasca default user
#
# [*sql_host*]
#   host of the mysql instance
#
# [*sql_user*]
#   name of the mysql user
#
# [*sql_password*]
#   password for the mysql user
#
# [*sql_port*]
#   port for the mysql instance
#
# [*persister_config_defaults*]
#   defaults for monasca persister settings
#
# [*pers_db_user*]
#   name of the monasca persister user for the database
#
# [*pers_db_password*]
#   password for the monasca persister database user
#
class monasca::params(
    $api_db_user        = 'mon_api',
    $api_db_password    = undef,
    $port               = '8070',
    $api_version        = 'v2.0',
    $region             = 'RegionOne',
    $admin_name         = 'monasca-admin',
    $agent_name         = 'monasca-agent',
    $user_name          = 'monasca-user',
    $auth_method        = 'token',
    $admin_password     = undef,
    $admin_project_name = undef,
    $agent_password     = undef,
    $user_password      = undef,
    $sql_host           = undef,
    $sql_user           = undef,
    $sql_password       = undef,
    $sql_port           = 3306,
    $pers_db_user       = 'mon_persister',
    $pers_db_password   = undef,
    $persister_config_defaults = {
      'admin_port'         => 8091,
      'application_port'   => 8090,
      'consumer_group_id'  => 1,
      'database_url'       => 'http://localhost:8086',
      'database_type'      => 'influxdb',
    }
) {
  include ::openstacklib::defaults
  validate_string($admin_password)
  validate_string($admin_project_name)
  validate_string($user_password)
  validate_string($agent_password)
  validate_string($sql_password)
  validate_string($sql_host)
  validate_string($api_db_password)
  validate_string($pers_db_password)

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
