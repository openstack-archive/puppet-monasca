# == Class: monasca::checks::memory
#
# Sets up the monasca memory check.
#
# === Parameters
#
# [*instances*]
#   A hash of instances for the check.
#   Each instance should be a hash of the check's parameters.
#   Parameters for the memory check are:
#       name (the instance key): The name of the instance.
#       dimensions
#   e.g.
#   instances:
#     memory_stats:
#       dimensions:
#
class monasca::checks::memory(
  $instances = undef,
){
  $conf_dir = $::monasca::agent::conf_dir

  if($instances){
    Concat["${conf_dir}/memory.yaml"] ~> Service['monasca-agent']
    concat { "${conf_dir}/memory.yaml":
      owner   => 'root',
      group   => $::monasca::group,
      mode    => '0640',
      warn    => true,
      require => File[$conf_dir],
    }
    concat::fragment { 'memory_header':
      target  => "${conf_dir}/memory.yaml",
      order   => '0',
      content => "---\ninit_config: null\ninstances:\n",
    }
    create_resources('monasca::checks::instances::memory', $instances)
  }
}
