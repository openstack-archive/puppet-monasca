# == Defined Type: monasca::checks::instances::http_check
#
# configure monasca plugin yaml file for http_check
#
# === Parameters:
#
# [*url*]
#   url to get http status for
#
# [*timeout*]
#   timeout in seconds for how long to wait for an http response
#
# [*username*]
#   username for keystone authentication
#
# [*password*]
#   password for keystone authentication
#
# [*match_pattern*]
#   expected patter in http response
#
# [*use_keystone*]
#   flag for whether to pass keystone token to url
#
# [*collect_response_time*]
#   flag to collect the http response time metric
#
# [*headers*]
#   any headers that should be passed to url
#
# [*disable_ssl_validation*]
#   flag to disable ssl validation
#
# [*dimensions*]
#   any additional dimensions for the check
#
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
