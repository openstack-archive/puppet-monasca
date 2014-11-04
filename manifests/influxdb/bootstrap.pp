#
# Class for bootstrapping influxdb for monasca
#
class monasca::influxdb::bootstrap(
  $influxdb_shard_config_source = 'puppet:///modules/monasca/shard_config.json'
)
{
  #
  # TODO: pull these from hiera (encrypt pwds)
  #
  $script = 'bootstrap-influxdb.py'
  $influxdb_host = 'localhost'
  $influxdb_port = 8086
  $influxdb_user = 'root'
  $influxdb_password = 'root'
  $influxdb_dbuser_password = 'password'
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

  file { "/tmp/${influxdb_shard_config}":
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
    require     => [Service['influxdb'], File["/tmp/${influxdb_shard_config}"]],
  }
}
