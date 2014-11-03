#
# Class for bootstrapping influxdb for monasca
#
class monasca::influxdb::bootstrap
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

  Package['influxdb'] ->
  exec { "/tmp/${script}":
    subscribe   => File["/tmp/${script}"],
    path        => '/bin:/sbin:/usr/bin:/usr/sbin:/tmp',
    cwd         => '/tmp',
    user        => 'root',
    group       => 'root',
    refreshonly => true,
    require     => Service['influxdb'],
  }
}
