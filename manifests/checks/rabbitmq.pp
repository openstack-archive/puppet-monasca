# == Class: monasca::checks::rabbitmq
#
# Sets up the monasca rabbitmq check.
#
# === Parameters
#
# [*instances*]
#   A hash of instances for the check.
#   Each instance should be a hash of the check's parameters.
#   Parameters for the rabbitmq check are:
#       name (the instance key): The name of the instance.
#       rabbitmq_user (default = guest)
#       rabbitmq_pass (default = guest)
#       rabbitmq_api_url (required)
#       queues
#       nodes
#       exchanges
#       max_detailed_queues
#       max_detailed_exchanges
#       max_detailed_nodes
#       dimensions
#   e.g.
#   instances:
#     rabbit:
#       rabbitmq_user: 'guest'
#       rabbitmq_pass: 'guest'
#       rabbitmq_api_url: 'http://localhost:15672/api'
#       exchanges: '[nova, cinder, ceilometer, glance, keystone, neutron, heat]'
#       nodes: '[rabbit@devstack]'
#       queues: '[conductor]'
#
class monasca::checks::rabbitmq(
  $instances = undef,
){
  $conf_dir = $::monasca::agent::conf_dir

  if($instances){
    Concat["${conf_dir}/rabbitmq.yaml"] ~> Service['monasca-agent']
    concat { "${conf_dir}/rabbitmq.yaml":
      owner   => 'root',
      group   => $::monasca::group,
      mode    => '0640',
      warn    => true,
      require => File[$conf_dir],
    }
    concat::fragment { 'rabbitmq_header':
      target  => "${conf_dir}/rabbitmq.yaml",
      order   => '0',
      content => "---\ninit_config: null\ninstances:\n",
    }
    create_resources('monasca::checks::instances::rabbitmq', $instances)
  }
}
