#
# configure monasca plugin yaml file for rabbitmq
#
define monasca::checks::instances::rabbitmq (
  $rabbitmq_api_url,
  $rabbitmq_user          = undef,
  $rabbitmq_pass          = undef,
  $queues                 = undef,
  $nodes                  = undef,
  $exchanges              = undef,
  $max_detailed_queues    = undef,
  $max_detailed_exchanges = undef,
  $max_detailed_nodes     = undef,
  $dimensions             = undef,
) {
  $conf_dir = $::monasca::agent::conf_dir
  concat::fragment { "${title}_rabbitmq_instance":
    target  => "${conf_dir}/rabbitmq.yaml",
    content => template('monasca/checks/rabbitmq.erb'),
    order   => '1',
  }
}
