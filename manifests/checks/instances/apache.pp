define monasca::checks::instances::apache (
  $apache_status_url,
  $dimensions = undef,
) {
  $conf_dir = $::monasca::agent::conf_dir
  concat::fragment { "${title}_apache_instance":
    target  => "${conf_dir}/apache.yaml",
    content => template('monasca/checks/apache.erb'),
    order   => '1',
  }
}
