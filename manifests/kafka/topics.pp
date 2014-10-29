#
# Defined type to create kafka topics for monasca
#
define monasca::kafka::topics (
  $kafka_zookeeper_connections,
  $kafka_replication_factor,
  $install_dir = '/opt/kafka',
) {
  $topic = $name
  exec { "kafka-topics.sh --create --zookeeper ${kafka_zookeeper_connections} --replication-factor ${kafka_replication_factor} --partitions 2 --topic ${topic}":
    path   => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${install_dir}/bin",
    cwd    => $install_dir,
    user   => 'root',
    group  => 'root',
    onlyif => "kafka-topics.sh --topic ${topic} --list --zookeeper ${kafka_zookeeper_connections}"
  }
}
