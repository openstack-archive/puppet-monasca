#
# Class to configure monasca api server's services:
#
#   monasca-persister
#   monasca-api
#
class monasca::apiserver::config (
  $zookeeper_servers = undef,
  $kafka_brokers = undef,
  $pers_db_user = 'mon_persister',
  $api_db_user = 'mon_api',
  $api_db_password = undef,
  $monasca_admin_user = 'monasca-admin',
  $sql_host = undef,
  $sql_user = undef,
  $sql_password = undef,
  $keystone_endpoint = undef,
  $keystone_admin_token = undef,
  $region_name = undef,
  $admin_password = undef,
) {

  $pers_cfg_file = '/etc/monasca/persister-config.yml'
  $api_cfg_file = '/etc/monasca/api-config.yml'
  $api_user = 'monasca_api'
  $pers_user = 'persister'
  $group = 'monasca'
  $logdir = '/var/log/monasca'

  user { $pers_user:
    ensure => present,
  }

  user { $api_user:
    ensure => present,
  }

  group { $group:
    ensure => present,
  }

  file { $logdir:
    ensure  => directory,
    owner   => $api_user,
    group   => $group,
    mode    => '0644',
    require => [User[$api_user], Group[$group]],
  }

  file { $pers_cfg_file:
    ensure  => file,
    content => template('monasca/persister-config.yml.erb'),
    mode    => '0644',
    owner   => $pers_user,
    group   => $group,
    require => [User[$pers_user], Group[$group], File[$logdir]],
  }

  file { $api_cfg_file:
    ensure  => file,
    content => template('monasca/api-config.yml.erb'),
    mode    => '0644',
    owner   => $api_user,
    group   => $group,
    require => [User[$api_user], Group[$group], File[$logdir]],
  }

  service { 'monasca-persister':
    ensure  => running,
    require => [User[$pers_user], Group[$group], File[$pers_cfg_file]],
  }

  service { 'monasca-api':
    ensure  => running,
    require => [User[$api_user], Group[$group], File[$api_cfg_file]],
  }
}
