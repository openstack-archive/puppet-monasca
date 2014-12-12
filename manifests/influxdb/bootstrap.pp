#
# Class for bootstrapping influxdb for monasca
#
class monasca::influxdb::bootstrap(
  $influxdb_shard_config_source = 'puppet:///modules/monasca/shard_config.json',
  $influxdb_password = undef,
  $influxdb_dbuser_ro_password = undef,
)
{
  include monasca::params

  $influxdb_dbuser_password = $::monasca::params::api_db_password
  $script = 'bootstrap-influxdb.py'
  $influxdb_host = 'localhost'
  $influxdb_port = 8086
  $influxdb_user = 'root'
  $influxdb_shard_config = '/tmp/config.json'

  ensure_packages('python-pip')

  python::pip { 'influxdb':
    ensure  => present,
    require => Package['python-pip'],
    before  => File["/tmp/${script}"],
  }

  file { "/tmp/${script}":
    ensure  => file,
    content => template("monasca/${script}.erb"),
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
  }

  file { $influxdb_shard_config:
    ensure => file,
    source => $influxdb_shard_config_source,
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
  }

  Package['influxdb'] ->
  exec { "/tmp/${script}":
    subscribe   => File["/tmp/${script}"],
    path        => '/bin:/sbin:/usr/bin:/usr/sbin:/tmp',
    cwd         => '/tmp',
    user        => 'root',
    group       => 'root',
    refreshonly => true,
    require     => [Service['influxdb'], File[$influxdb_shard_config]],
  }
}
