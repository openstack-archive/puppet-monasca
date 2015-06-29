# == Defined Type: monasca::checks::instances::rabbitmq
#
# configure monasca plugin yaml file for rabbitmq
#
# === Parameters:
#
# [*rabbitmq_api_url*]
#   url of rabbit server
#
# [*rabbitmq_user*]
#   username for rabbit server
#
# [*rabbitmq_pass*]
#   password for rabbit server
#
# [*queues*]
#   rabbit queues to check
#
# [*nodes*]
#   rabbit nodes to check
#
# [*exchanges*]
#   rabbit exchanges to check
#
# [*max_detailed_queues*]
#   maximum number of detailed queues to check
#
# [*max_detailed_exchanges*]
#   maximum number of detailed exchanges to check
#
# [*max_detailed_nodes*]
#   maximum number of detailed nodes to check
#
# [*dimensions*]
#   any additional dimensions for the check
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
