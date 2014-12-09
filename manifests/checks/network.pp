# == Class: monasca::checks::network
#
# Sets up the monasca network check.
#
# === Parameters
#
# [*instances*]
#   An array of instances for the check.
#   Each instance should be a hash of the check's parameters.
#   Parameters for the network check are:
#       collect_connection_state (default = False)
#       excluded_interfaces
#       excluded_interface_re: A regular expression for excluded interfaces
#       dimensions
#   e.g.
#   $instances = [{collect_connection_state => 'False',
#                  excluded_interfaces => '[lo, lo0]'}]
#
class monasca::checks::network(
  $instances = [],
){
  $conf_dir = $::monasca::agent::conf_dir

  File["${conf_dir}/network.yaml"] ~> Service['monasca-agent']

  file { "${conf_dir}/network.yaml":
    owner   => 'root',
    group   => 'monasca-agent',
    mode    => '0640',
    content => template('monasca/checks/generic.yaml.erb'),
    require => File[$conf_dir],
  }

}