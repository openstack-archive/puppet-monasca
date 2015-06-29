# == Defined Type: monasca::kafka::topics
#
# Defined type to create kafka topics for monasca
#
# === Parameters:
#
# [*partitions*]
#   number of kafka partitions for this topic
#
# [*kafka_zookeeper_connections*]
#   list of zookeeper connections for kafka topic
#
# [*kafka_replication_factor*]
#   replication factor for kakfa topic
#
# [*install_dir*]
#   directory of kafka install
#
define monasca::kafka::topics (
  $partitions                  = 2,
  $kafka_zookeeper_connections = $monasca::kafka::config::kafka_zookeeper_connections,
  $kafka_replication_factor    = $monasca::kafka::config::kafka_replication_factor,
  $install_dir                 = '/opt/kafka',
) {

  exec { "Ensure ${name} is created":
    command =>"kafka-topics.sh --create --zookeeper ${kafka_zookeeper_connections} --replication-factor ${kafka_replication_factor} --partitions ${partitions} --topic ${name}",
    path    => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${install_dir}/bin",
    cwd     => $install_dir,
    user    => 'root',
    group   => 'root',
    onlyif  => "kafka-topics.sh --topic ${name} --list --zookeeper ${kafka_zookeeper_connections}"
  } ->
  exec { "Ensure ${name} is has ${partitions} partitions":
    command =>"kafka-topics.sh --alter --zookeeper ${kafka_zookeeper_connections} --partitions ${partitions} --topic ${name}",
    path    => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${install_dir}/bin",
    cwd     => $install_dir,
    user    => 'root',
    group   => 'root',
  }
}
