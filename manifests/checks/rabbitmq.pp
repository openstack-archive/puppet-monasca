# == Class: monasca::checks::rabbitmq
#
# Sets up the monasca rabbitmq check.
#
# === Parameters
#
# [*instances*]
#   An array of instances for the check.
#   Each instance should be a hash of the check's parameters.
#   Parameters for the rabbitmq check are:
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
#   $instances = [{rabbitmq_user => 'guest',
#                  rabbitmq_pass => 'guest',
#                  rabbitmq_api_url => 'http://localhost:15672/api',
#                  exchanges => '[[nova, cinder, ceilometer, glance, keystone, neutron, heat]',
#                  nodes => '[rabbit@devstack]',
#                  queues => '[conductor]'}]
#
class monasca::checks::rabbitmq(
  $instances = [],
){
  $conf_dir = $::monasca::agent::conf_dir

  File["${conf_dir}/rabbitmq.yaml"] ~> Service['monasca-agent']

  file { "${conf_dir}/rabbitmq.yaml":
    owner   => 'root',
    group   => $::monasca::group,
    mode    => '0640',
    content => template('monasca/checks/generic.yaml.erb'),
    require => File[$conf_dir],
  }

}