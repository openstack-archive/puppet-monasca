#
# Class for creating kafka topics needed by monasca
#
class monasca::kafka::config (
  $kafka_zookeeper_connections = undef,
  $kafka_replication_factor = undef,
) {

  $topics = [
    'metrics',
    'events',
    'alarm-notification',
    'alarm-state-transitions',
    'healthcheck']

  monasca::kafka::topics { $topics:
    kafka_zookeeper_connections => $kafka_zookeeper_connections,
    kafka_replication_factor    => $kafka_replication_factor,
  }
}
