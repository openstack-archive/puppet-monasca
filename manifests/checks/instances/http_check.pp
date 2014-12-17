define monasca::checks::instances::http_check (
  $url,
  $timeout                = undef,
  $username               = undef,
  $password               = undef,
  $match_pattern          = undef,
  $use_keystone           = undef,
  $collect_response_time  = undef,
  $headers                = undef,
  $disable_ssl_validation = undef,
  $dimensions             = undef,
) {
  $conf_dir = $::monasca::agent::conf_dir
  concat::fragment { "${title}_http_check_instance":
    target  => "${conf_dir}/http_check.yaml",
    content => template('monasca/checks/http_check.erb'),
    order   => '1',
  }
}
