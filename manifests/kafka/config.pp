# == Class: monasca::kakfa::config
#
# Class for creating kafka topics needed by monasca
#
# === Parameters:
#
# [*kafka_zookeeper_connections*]
#   list of zookeeper servers and ports
#
# [*kafka_replication_factor*]
#   replication factor for kafka
#
# [*topic_config*]
#   topic specific topic configuration, sample hiera:
#
#   monasca::kafka::config::topic_config:
#     metrics:
#       partitions: 4
#     events:
#       partitions: 4
#     alarm-notifications:
#       partitions: 8
#     alarm-state-transitions:
#       partitions: 8
#     retry-notifications:
#       partitions: 2
#     healthcheck:
#       partitions: 4
#
class monasca::kafka::config (
  $kafka_zookeeper_connections = undef,
  $kafka_replication_factor    = undef,
  $topic_config                = {},
) {
  create_resources('monasca::kafka::topics', $topic_config)
}
