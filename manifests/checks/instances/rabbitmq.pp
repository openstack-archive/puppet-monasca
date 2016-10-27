# == Defined Type: monasca::checks::instances::rabbitmq
#
# configure monasca plugin yaml file for rabbitmq
#
# === Parameters:
#
# [*rabbitmq_api_url*]
#   (Required) url of rabbit server
#
# [*rabbitmq_user*]
#   (Optional) username for rabbit server
#   Defaults to undef.
#
# [*rabbitmq_pass*]
#   (Optional) password for rabbit server
#   Defaults to undef.
#
# [*queues*]
#   (Optional) an explicit list of rabbit queues to check
#   Defaults to undef.
#
# [*nodes*]
#   (Optional) an explicit list of rabbit nodes to check
#   Defaults to undef.
#
# [*exchanges*]
#   (Optional) an explicit list of rabbit exchanges to check
#   Defaults to undef.
#
# [*queues_regexes*]
#   (Optional) a list of regex for rabbit queues to check
#   Defaults to undef.
#
# [*nodes_regexes*]
#   (Optional) a list of regex for rabbit nodes to check
#   Defaults to undef.
#
# [*exchanges_regexes*]
#   (Optional) a list of regex for rabbit exchanges to check
#   Defaults to undef.
#
# [*max_detailed_queues*]
#   (Optional) maximum number of detailed queues to check
#   Defaults to undef.
#
# [*max_detailed_exchanges*]
#   (Optional) maximum number of detailed exchanges to check
#   Defaults to undef.
#
# [*max_detailed_nodes*]
#   (Optional) maximum number of detailed nodes to check
#   Defaults to undef.
#
# [*whitelist*]
#   (Optional) A dictionary of the node, queue and exchange metrics to collect
#   Defaults to undef.
#
# [*dimensions*]
#   (Optional) any additional dimensions for the check
#   Defaults to undef.
#
define monasca::checks::instances::rabbitmq (
  $rabbitmq_api_url,
  $rabbitmq_user          = undef,
  $rabbitmq_pass          = undef,
  $queues                 = undef,
  $nodes                  = undef,
  $exchanges              = undef,
  $queues_regexes         = undef,
  $nodes_regexes          = undef,
  $exchanges_regexes      = undef,
  $max_detailed_queues    = undef,
  $max_detailed_exchanges = undef,
  $max_detailed_nodes     = undef,
  $whitelist              = undef,
  $dimensions             = undef,
) {
  $conf_dir = $::monasca::agent::conf_dir
  concat::fragment { "${title}_rabbitmq_instance":
    target  => "${conf_dir}/rabbitmq.yaml",
    content => template('monasca/checks/rabbitmq.erb'),
    order   => '1',
  }
}
