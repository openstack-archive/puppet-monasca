# == Class: monasca::checks::network
#
# Sets up the monasca network check.
#
# === Parameters
#
# [*instances*]
#   A hash of instances for the check.
#   Each instance should be a hash of the check's parameters.
#   Parameters for the network check are:
#       name (the instance key): The name of the instance.
#       collect_connection_state (default = False)
#       excluded_interfaces
#       excluded_interface_re: A regular expression for excluded interfaces
#       use_bits
#       dimensions
#   e.g.
#   instances:
#     network_stats:
#       collect_connection_state: 'False'
#       excluded_interfaces: '[lo, lo0]'
#
class monasca::checks::network(
  $instances = undef,
){
  $conf_dir = $::monasca::agent::conf_dir

  if($instances){
    Concat["${conf_dir}/network.yaml"] ~> Service['monasca-agent']
    concat { "${conf_dir}/network.yaml":
      owner   => 'root',
      group   => $::monasca::group,
      mode    => '0640',
      warn    => true,
      require => File[$conf_dir],
    }
    concat::fragment { 'network_header':
      target  => "${conf_dir}/network.yaml",
      order   => '0',
      content => "---\ninit_config: null\ninstances:\n",
    }
    create_resources('monasca::checks::instances::network', $instances)
  }
}
