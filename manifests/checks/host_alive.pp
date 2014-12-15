# == Class: monasca::checks::host_alive
#
# Sets up the monasca host_alive check.
#
# === Parameters
# [*ssh_port*]
#
# [*ssh_timeout*]
#   ssh_timeout is a floating-point number of seconds
# [*ping_timeout*]
#   ping_timeout is an integer number of seconds
# [*instances*]
#   An array of instances for the check.
#   Each instance should be a hash of the check's parameters.
#   Parameters for the host_alive check are:
#       host_name (required)
#       alive_test (required)
#   e.g.
#   $instances = [{host_name => 'somehost.somedomain.net',
#                  alive_test => 'ssh'},
#                  {host_name => 'gateway.somedomain.net',
#                  alive_test => 'ping'},
#                  {host_name => '192.168.0.221',
#                  alive_test => 'ssh'}]
#
class monasca::checks::host_alive(
  $ssh_port     = '22',
  $ssh_timeout  = '0.5',
  $ping_timeout = '1',
  $instances   = [],
){
  $conf_dir = $::monasca::agent::conf_dir

  File["${conf_dir}/host_alive.yaml"] ~> Service['monasca-agent']
  
  file { "${conf_dir}/host_alive.yaml":
    owner   => 'root',
    group   => $::monasca::group,
    mode    => '0640',
    content => template('monasca/checks/host_alive.yaml.erb'),
    require => File[$conf_dir],
  }

}