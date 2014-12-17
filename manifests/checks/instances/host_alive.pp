define monasca::checks::instances::host_alive (
  $host_name,
  $alive_test,
) {
  $conf_dir = $::monasca::agent::conf_dir
  concat::fragment { "${title}_host_alive_instance":
    target  => "${conf_dir}/host_alive.yaml",
    content => template('monasca/checks/host_alive.erb'),
    order   => '1',
  }
}
