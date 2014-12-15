# == Class: monasca::checks::zk
#
# Sets up the monasca zookeeper check.
#
# === Parameters
#
# [*instances*]
#   An array of instances for the check.
#   Each instance should be a hash of the check's parameters.
#   Parameters for the zk check are:
#       host (default = localhost)
#       port (default = 2181)
#       timeout (default = 3.0)
#       dimensions
#   e.g.
#   $instances = [{host => 'localhost',
#                  port => '2181',
#                  timeout => '3'}]
#
class monasca::checks::zk(
  $instances = [],
){
  $conf_dir = $::monasca::agent::conf_dir

  File["${conf_dir}/zk.yaml"] ~> Service['monasca-agent']

  file { "${conf_dir}/zk.yaml":
    owner   => 'root',
    group   => $::monasca::group,
    mode    => '0640',
    content => template('monasca/checks/generic.yaml.erb'),
    require => File[$conf_dir],
  }

}