# == Class: monasca::checks::http_check
#
# Sets up the monasca http_check check.
#
# === Parameters
#
# [*instances*]
#   A hash of instances for the check.
#   Each instance should be a hash of the check's parameters.
#   Parameters for the http_check check are:
#       name (the instance key): The name of the instance.
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
#   instances:
#     nova-api:
#       url: 'http://192.168.0.254:8774/v2.0'
#       dimensions: '{service: compute_api}'
#       match_pattern: '.*version=2.*'
#       timeout: '10'
#       use_keystone: 'True'
#       collect_response_time: 'True'
#
class monasca::checks::http_check(
  $instances = undef,
){
  $conf_dir = $::monasca::agent::conf_dir

  if($instances){
    Concat["${conf_dir}/http_check.yaml"] ~> Service['monasca-agent']
    concat { "${conf_dir}/http_check.yaml":
      owner   => 'root',
      group   => $::monasca::group,
      mode    => '0640',
      warn    => true,
      require => File[$conf_dir],
    }
    concat::fragment { 'http_check_header':
      target  => "${conf_dir}/http_check.yaml",
      order   => '0',
      content => "---\ninit_config: null\ninstances:\n",
    }
    create_resources('monasca::checks::instances::http_check', $instances)
  }
}
