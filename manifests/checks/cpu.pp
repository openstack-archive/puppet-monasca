# == Class: monasca::checks::cpu
#
# Sets up the monasca cpu check.
#
# === Parameters
#
# [*instances*]
#   A hash of instances for the check.
#   Each instance should be a hash of the check's parameters.
#   Parameters for the cpu check are:
#       name (the instance key): The name of the instance.
#       send_rollup_stats (default = False)
#       dimensions
#   e.g.
#   instances:
#     cpu_stats:
#       dimensions:
#
class monasca::checks::cpu(
  $instances = undef,
){
  $conf_dir = $::monasca::agent::conf_dir

  if($instances){
    Concat["${conf_dir}/cpu.yaml"] ~> Service['monasca-agent']
    concat { "${conf_dir}/cpu.yaml":
      owner   => 'root',
      group   => $::monasca::group,
      mode    => '0640',
      warn    => true,
      require => File[$conf_dir],
    }
    concat::fragment { 'cpu_header':
      target  => "${conf_dir}/cpu.yaml",
      order   => '0',
      content => "---\ninit_config: null\ninstances:\n",
    }
    create_resources('monasca::checks::instances::cpu', $instances)
  }
}
