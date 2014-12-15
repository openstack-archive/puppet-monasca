# == Class: monasca::checks::http_check
#
# Sets up the monasca http_check check.
#
# === Parameters
#
# [*instances*]
#   An array of instances for the check.
#   Each instance should be a hash of the check's parameters.
#   Parameters for the http_check check are:
#       url (required)
#       timeout (default = 10)
#       username
#       password
#       match_pattern
#       use_keystone (default = False)
#       collect_response_time (default = False)
#       headers
#       disable_ssl_validation (default = True)
#       dimensions
#   e.g.
#   $instances = [{url => 'http://192.168.0.254:8774/v2.0',
#                  dimensions => '{service: compute_api}',
#                  match_pattern => '.*version=2.*',
#                  timeout => '10',
#                  use_keystone => 'True',
#                  collect_response_time => 'True'}]
#
class monasca::checks::http_check(
  $instances = [],
){
  $conf_dir = $::monasca::agent::conf_dir

  File["${conf_dir}/http_check.yaml"] ~> Service['monasca-agent']

  file { "${conf_dir}/http_check.yaml":
    owner   => 'root',
    group   => $::monasca::group,
    mode    => '0640',
    content => template('monasca/checks/generic.yaml.erb'),
    require => File[$conf_dir],
  }

}