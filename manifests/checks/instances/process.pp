define monasca::checks::instances::process (
  $search_string,
  $exact_match        = undef,
  $cpu_check_interval = undef,
  $dimensions         = undef,
) {
  $conf_dir = $::monasca::agent::conf_dir
  concat::fragment { "${title}_process_instance":
    target  => "${conf_dir}/process.yaml",
    content => template('monasca/checks/process.erb'),
    order   => '1',
  }
}

