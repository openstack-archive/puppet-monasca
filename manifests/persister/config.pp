# == Defined Type: monasca::persister::config
#
# Defined type to setup monasca persister
#
# === Parameters:
#
# [*batch_seconds*]
#   frequency for this perisiter to write to db
#
# [*batch_size*]
#   batch size of metrics/alarm to persist at the same time
#
# [*check_conn_while_idle*]
#   flag for whether db connection should stay alive while idle
#
# [*config*]
#   persister specific configuration -- allows running multiple persisters.
#
# [*consumer_id*]
#   id of the kafka consumer for this persister
#
# [*database_type*]
#   influxdb or vertica
#
# [*db_admin_password*]
#   admin password for database
#
# [*gzip_setting*]
#   true for gzipping http data
#
# [*num_threads*]
#   number of persister threads to run
#
# [*pers_db_user*]
#   name of the monasca perisister database user
#
# [*pers_user*]
#   name of the monasca perisister default user
#
# [*replication_factor*]
#   replication factor for this persister
#
# [*retention_policy*]
#   retention policy for this persister
#
# [*zookeeper_servers*]
#   list of zookeeper servers
#
define monasca::persister::config (
  $batch_seconds         = $monasca::persister::batch_seconds,
  $batch_size            = $monasca::persister::batch_size,
  $check_conn_while_idle = true,
  $config                = {},
  $consumer_id           = $monasca::persister::consumer_id,
  $database_type         = $monasca::persister::database_type,
  $db_admin_password     = $monasca::persister::db_admin_password,
  $gzip_setting          = true,
  $num_threads           = $monasca::persister::num_threads,
  $pers_user             = $monasca::persister::pers_user,
  $replication_factor    = 1,
  $retention_policy      = 'raw',
  $zookeeper_servers     = $monasca::persister::zookeeper_servers,
) {
  include ::monasca::params
  $persister_config = deep_merge($monasca::params::persister_config_defaults, $config)

  $persister_service_name = $name
  $pers_cfg_file = "/etc/monasca/${persister_service_name}.yml"
  $pers_db_user     = $::monasca::params::pers_db_user
  $pers_db_password = $::monasca::params::pers_db_password

  file { $pers_cfg_file:
    ensure  => file,
    content => template('monasca/persister-config.yml.erb'),
    mode    => '0644',
    owner   => $pers_user,
    group   => $::monasca::group,
    require => [User[$pers_user], Group[$::monasca::group], File[$::monasca::log_dir]],
  } ~> Service[$persister_service_name]

  service { $persister_service_name:
    ensure  => running,
    require => [File[$pers_cfg_file], Package['install-persister'],
                Monasca::Persister::Startup_script[$persister_service_name]],
    tag     => 'monasca-service',
  }

  monasca::persister::startup_script { $persister_service_name:
    require => Package['install-persister'],
  }

}
