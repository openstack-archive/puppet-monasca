# == Class: monasca::checks::process
#
# Sets up the monasca process check.
#
# === Parameters
#
# [*instances*]
#   An array of instances for the check.
#   Each instance should be a hash of the check's parameters.
#   Parameters for the process check are:
#       name (required): The name of the instance.
#       search_string (required): An array of process names to search for.
#       exact_match (default = True): Whether the search_string should exactly
#           match the service name. (Boolean)
#       cpu_check_interval (default = 0.1):
#       dimensions: Additional dimensions for the instance.
#   e.g.
#   $instances = [{name => 'nova-api',
#                  search_string => '[nova-api]',
#                  dimensions => '{component: nova-api, service: compute}'},
#                 {name => 'ssh',
#                  search_string => '['ssh', 'sshd']'}
#                 {name => 'mysql',
#                  search_string => '[mysql]',
#                  exact_match => 'True'}]
#
class monasca::checks::process(
  $instances = [],
){
  $conf_dir = $::monasca::agent::conf_dir

  File["${conf_dir}/process.yaml"] ~> Service['monasca-agent']

  file { "${conf_dir}/process.yaml":
    owner   => 'root',
    group   => $::monasca::group,
    mode    => '0640',
    content => template('monasca/checks/generic.yaml.erb'),
    require => File[$conf_dir],
  }

}