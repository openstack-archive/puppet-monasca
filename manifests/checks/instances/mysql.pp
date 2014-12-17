define monasca::checks::instances::mysql (
  $server        = undef,
  $user          = undef,
  $port          = undef,
  $pass          = undef,
  $sock          = undef,
  $defaults_file = undef,
  $dimensions    = undef,
  $options       = undef,
) {
  $conf_dir = $::monasca::agent::conf_dir
  concat::fragment { "${title}_mysql_instance":
    target  => "${conf_dir}/mysql.yaml",
    content => template('monasca/checks/mysql.erb'),
    order   => '1',
  }
}
