# == Class: monasca::checks::load
#
# Sets up the monasca load check.
#
# === Parameters
#
# [*instances*]
#   A hash of instances for the check.
#   Each instance should be a hash of the check's parameters.
#   Parameters for the load check are:
#       name (the instance key): The name of the instance.
#       dimensions
#   e.g.
#   instances:
#     load_stats:
#       dimensions:
#
class monasca::checks::load(
  $instances = undef,
){
  $conf_dir = $::monasca::agent::conf_dir

  if($instances){
    Concat["${conf_dir}/load.yaml"] ~> Service['monasca-agent']
    concat { "${conf_dir}/load.yaml":
      owner   => 'root',
      group   => $::monasca::group,
      mode    => '0640',
      warn    => true,
      require => File[$conf_dir],
    }
    concat::fragment { 'load_header':
      target  => "${conf_dir}/load.yaml",
      order   => '0',
      content => "---\ninit_config: null\ninstances:\n",
    }
    create_resources('monasca::checks::instances::load', $instances)
  }
}
