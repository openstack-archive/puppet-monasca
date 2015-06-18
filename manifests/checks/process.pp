# == Class: monasca::checks::process
#
# Sets up the monasca process check.
#
# === Parameters
#
# [*instances*]
#   A hash of instances for the check.
#   Each instance should be a hash of the check's parameters.
#   Parameters for the process check are:
#       name (the instance key): The name of the instance.
#       search_string (required): An array of process names to search for.
#       exact_match (default = True): Whether the search_string should exactly
#           match the service name. (Boolean)
#       cpu_check_interval (default = 0.1):
#       dimensions: Additional dimensions for the instance.
#   e.g.
#   instances:
#     nova-api:
#       search_string: '[nova-api]'
#       dimensions: '{component: nova-api, service: compute}'
#     rabbitmq-server:
#       search_string: '[rabbitmq-server]'
#
class monasca::checks::process(
  $instances = undef,
){
  $conf_dir = $::monasca::agent::conf_dir

  if($instances){
    Concat["${conf_dir}/process.yaml"] ~> Service['monasca-agent']
    concat { "${conf_dir}/process.yaml":
      owner   => 'root',
      group   => $::monasca::group,
      mode    => '0640',
      warn    => true,
      require => File[$conf_dir],
    }
    concat::fragment { 'process_header':
      target  => "${conf_dir}/process.yaml",
      order   => '0',
      content => "---\ninit_config: null\ninstances:\n",
    }
    create_resources('monasca::checks::instances::process', $instances)
  }
}
