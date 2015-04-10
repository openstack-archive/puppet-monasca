#
# Defined type to setup monasca persister
#
define monasca::persister::config (
  $batch_seconds      = $monasca::persister::batch_seconds,
  $batch_size         = $monasca::persister::batch_size,
  $config             = {},
  $consumer_id        = $monasca::persister::consumer_id,
  $database_type      = 'influxdb',
  $gzip_setting       = true,
  $num_threads        = $monasca::persister::num_threads,
  $pers_db_user       = 'mon_persister',
  $pers_user          = $monasca::persister::pers_user,
  $replication_factor = 1,
  $retention_policy   = 'raw',
  $zookeeper_servers  = $monasca::persister::zookeeper_servers,
) {
  include monasca::params
  $persister_config = deep_merge($monasca::params::persister_config_defaults, $config)

  $persister_service_name = $name
  $pers_cfg_file = "/etc/monasca/${persister_service_name}.yml"
  $api_db_password = $::monasca::params::api_db_password

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
  }

  monasca::persister::startup_script { $persister_service_name:
    require => Package['install-persister'],
  }

}
