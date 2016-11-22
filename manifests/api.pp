# == Class: monasca::api
#
# Class to setup monasca api
#
# === Parameters:
#
# [*api_db_thread_min*]
#   (Optional) Minimum number of threads for db connection pool.
#   Defaults to 4.
#
# [*api_db_thread_max*]
#   (Optional) Maximum number of threads for db connection pool.
#   Defaults to 32.
#
# [*api_db_wait*]
#   (Optional) Amount of time to wait for db connection.  Can specify
#   any string supported by io.dropwizard Duration class, for example:
#
#     '1ns' is 1 nanosecond
#     '1s'  is 1 seconds
#     '1m'  is 1 minute
#     '1h'  is 1 hour
#     '1d'  is 1 day
#
#   Defaults to '5s' (5 seconds).
#
# [*api_user*]
#   (Optional) Name of the monasca api user.
#   Defaults to 'monasca_api'.
#
# [*blobmirror*]
#   (Optional) URL of server to install debians from.
#   Defaults to undef.
#
# [*check_conn_while_idle*]
#   (Optional) Flag for whether db connection should stay alive while idle.
#   Defaults to true.
#
# [*database_type*]
#   (Optional) Type of database backend, influxdb or vertica.
#   Defaults to influxdb.
#
# [*database_host*]
#   (Optional) Host of database backend.
#   Defaults to localhost.
#
# [*db_admin_password*]
#   (Optional) Database admin password.
#   Defaults to undef.
#
# [*gzip_setting*]
#   (Optional) Flag for whether to use gzip for monasca api and persister.
#   Defaults to true.
#
# [*kafka_brokers*]
#   (Optional) List of kafka brokers and ports.
#   Defaults to undef.
#
# [*keystone_endpoint*]
#   (Optional) URL of keystone server.
#   Defaults to undef.
#
# [*keystone_admin_token*]
#   (Optional) Token for keystone admin.
#   Defaults to undef.
#
# [*max_query_limit*]
#   (Optional) Maximum number of records to be returned from db.
#   Defaults to 10000.
#
# [*mon_api_build_ver*]
#   (Optional) Build version of the monasca api debian package.
#   Defaults to undef.
#
# [*mon_api_deb*]
#   (Optional) Name of the monasca api debian package.
#   Defaults to undef.
#
# [*region_name*]
#   (Optional) Openstack region name for this install.
#   Defaults to NA.
#
# [*roles_agent*]
#   (Optional) List with the names of roles allowed to write metrics.
#   Defaults to ['monasca-agent'].
#
# [*role_delegate*]
#   (Optional) Name of the role allowed to write cross tenant metrics.
#   Defaults to 'monitoring-delegate'.
#
# [*role_admin*]
#   (Optional) Name of the role with extended permissions. Includes ability to
#   publish metrics older than two weeks.
#   Defaults to 'monasca-admin'.
#
# [*roles_default*]
#   (Optional) List with the names of roles allowed to read and write metrics.
#   Defaults to ['admin','monasca-user', '_member_'].
#
# [*roles_read_only*]
#   (Optional) List with the names of roles allowed only to read metrics.
#   Defaults to [].
#
# [*vertica_db_hint*]
#   (Optional) Database hint to pass to vertica.
#   Defaults to "".  Setting this to "/*+KV*/" tells vertica to satisfy the
#   query locally without talking to other nodes in the cluster -- which reduces
#   network chatter when projections are replicated on each node.
#
# [*valid_notif_periods*]
#   (Optional) List of valid notification periods in seconds.
#   Defaults to [60].
#
# [*zookeeper_servers*]
#   (Optional) Comma separated list of zookeeper servers and ports.
#   Defaults to undef.
#   Example: "zookeeper_host_1:2181,zookeeper_host_2:2181"
#
class monasca::api (
  $api_db_thread_min     = 4,
  $api_db_thread_max     = 32,
  $api_db_wait           = '5s',
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
  $max_query_limit       = 10000,
  $mon_api_build_ver     = undef,
  $mon_api_deb           = undef,
  $region_name           = 'NA',
  $role_delegate         = 'monitoring-delegate',
  $role_admin            = 'monasca-admin',
  $roles_agent           = ['monasca-agent'],
  $roles_default         = ['admin','monasca-user','_member_'],
  $roles_read_only       = [],
  $valid_notif_periods   = [60],
  $vertica_db_hint       = '',
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
  $admin_password     = $::monasca::params::admin_password
  $admin_project_name = $::monasca::params::admin_project_name
  $admin_name         = $::monasca::params::admin_name
  $auth_method        = $::monasca::params::auth_method
  $sql_host           = $::monasca::params::sql_host
  $sql_user           = $::monasca::params::sql_user
  $sql_password       = $::monasca::params::sql_password
  $sql_port           = $::monasca::params::sql_port
  $monasca_api_port   = $::monasca::params::port
  $api_db_user        = $::monasca::params::api_db_user
  $api_db_password    = $::monasca::params::api_db_password

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
  } ~> Service['monasca-api']
}
