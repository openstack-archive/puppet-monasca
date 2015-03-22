#
# Class for creating kafka topics needed by monasca
#
class monasca::kafka::config (
  $kafka_zookeeper_connections = undef,
  $kafka_replication_factor    = undef,
  $topic_config                = {},
) {
  create_resources('monasca::kafka::topics', $topic_config)
}
