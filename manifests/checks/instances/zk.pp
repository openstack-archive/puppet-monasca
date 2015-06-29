# == Defined Type: monasca::checks::instances::zk
#
# configure monasca plugin yaml file for zookeeper
#
# === Parameters:
#
# [*host*]
#   zookeeper host
#
# [*port*]
#   zookeeper port
#
# [*timeout*]
#   timeout in seconds to wait for zookeeper to respond
#
# [*dimensions*]
#   any additional dimensions for the check
#
define monasca::checks::instances::zk (
  $host       = undef,
  $port       = undef,
  $timeout    = undef,
  $dimensions = undef,
) {
  $conf_dir = $::monasca::agent::conf_dir
  concat::fragment { "${title}_zk_instance":
    target  => "${conf_dir}/zk.yaml",
    content => template('monasca/checks/zk.erb'),
    order   => '1',
  }
}
