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
