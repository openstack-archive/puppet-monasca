# == Class: monasca::api
#
# Class to setup monasca api
#
# === Parameters:
#
# [*api_user*]
#   name of the monasca api user
#
# [*blobmirror*]
#   url of server to install debians from
#
# [*check_conn_while_idle*]
#   flag for whether db connection should stay alive while idle
#
# [*database_type*]
#   type of database backend, influxdb or vertica
#
# [*database_host*]
#   host of database backend, defaults to localhost
#
# [*db_admin_password*]
#   database admin password
#
# [*gzip_setting*]
#   flag for whether to use gzip for monasca api and persister
#
# [*kafka_brokers*]
#   list of kafka brokers and ports
#
# [*keystone_endpoint*]
#   url of keystone server
#
# [*keystone_admin_token*]
#   token for keystone admin
#
# [*mon_api_build_ver*]
#   build version of the monasca api debian package
#
# [*mon_api_deb*]
#   name of the monasca api debian package
#
# [*region_name*]
#   openstack region name for this install
#
# [*role_delegate*]
#   name of the monasca delegate role
#
# [*roles_default*]
#   name of the monasca default role
#
# [*roles_agent*]
#   name of the monasca agent role
#
# [*zookeeper_servers*]
#   list of zookeeper servers and ports
#
class monasca::api (
  $api_user              = 'monasca_api',
  $blobmirror            = undef,
  $check_conn_while_idle = true,
  $database_type         = 'influxdb',
  $database_host         = 'localhost',
  $db_admin_password     = undef,
  $gzip_setting          = true,
  $kafka_brokers         = undef,
  $keystone_endpoint     = undef,
  $keystone_admin_token  = undef,
  $mon_api_build_ver     = undef,
  $mon_api_deb           = undef,
  $region_name           = 'NA',
  $role_delegate         = 'monitoring-delegate',
  $roles_default         = ['admin','monasca-user','_member_'],
  $roles_agent           = ['monasca-agent'],
  $zookeeper_servers     = undef,
) {
  include ::monasca
  include ::monasca::params

  $api_fetch_url = "http://${blobmirror}/repos/monasca/monasca_api"
  $latest_api_deb = "/tmp/${mon_api_deb}"
  $api_cfg_file = '/etc/monasca/api-config.yml'
  $stack_script_src = 'puppet:///modules/monasca/monasca_stack.sh'
  $stack_script = '/usr/bin/monasca_stack.sh'
  $startup_script = '/etc/init/monasca-api.conf'
  $startup_script_src = 'puppet:///modules/monasca/monasca-api.conf'

  wget::fetch { "${api_fetch_url}/${mon_api_build_ver}/${mon_api_deb}":
    destination => $latest_api_deb,
    timeout     => 300,
    before      => [Package['install-api'],File[$latest_api_deb]],
  } ~> Service['monasca-api']

  user { $api_user:
    ensure  => present,
    groups  => $::monasca::group,
    require => Group[$::monasca::group],
  }

  file { $latest_api_deb:
    ensure => present,
  }

  package { 'monasca-api':
    ensure   => latest,
    provider => dpkg,
    source   => $latest_api_deb,
    alias    => 'install-api',
    tag      => ['openstack', 'monasca-package'],
  }

  #Variables for the template
  $admin_password = $::monasca::params::admin_password
  $admin_name = $::monasca::params::admin_name
  $auth_method = $::monasca::params::auth_method
  $sql_host = $::monasca::params::sql_host
  $sql_user = $::monasca::params::sql_user
  $sql_password = $::monasca::params::sql_password
  $monasca_api_port = $::monasca::params::port
  $api_db_user = $::monasca::params::api_db_user
  $api_db_password = $::monasca::params::api_db_password

  file { $api_cfg_file:
    ensure  => file,
    content => template('monasca/api-config.yml.erb'),
    mode    => '0644',
    owner   => $api_user,
    group   => $::monasca::group,
    require => [User[$api_user], Group[$::monasca::group], File[$::monasca::log_dir]],
  } ~> Service['monasca-api']

  service { 'monasca-api':
    ensure  => running,
    require => [File[$api_cfg_file],
                File[$latest_api_deb],
                File[$startup_script],
                Package['install-api']],
    tag     => 'monasca-service',
  }

  # Remove any old debs (puppet won't delete current resources)
  tidy { '/tmp':
    matches => 'monasca*.deb',
    recurse => true,
  }

  file { $stack_script:
    ensure => file,
    source => $stack_script_src,
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
  }

  file { $startup_script:
    ensure => file,
    source => $startup_script_src,
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
  }
}
