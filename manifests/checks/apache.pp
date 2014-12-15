# == Class: monasca::checks::apache
#
# Sets up the monasca apache check.
#
# === Parameters
#
# [*instances*]
#   An array of instances for the check.
#   Each instance should be a hash of the check's parameters.
#   Parameters for the apache check are:
#       apache_status_url (required)
#       dimensions
#   e.g.
#   $instances = [{apache_status_url => 'http://your.server.name/server-status'}]
#
class monasca::checks::apache(
  $instances = [],
){
  $conf_dir = $::monasca::agent::conf_dir

  File["${conf_dir}/apache.yaml"] ~> Service['monasca-agent']
  
  file { "${conf_dir}/apache.yaml":
    owner   => 'root',
    group   => $::monasca::group,
    mode    => '0640',
    content => template('monasca/checks/generic.yaml.erb'),
    require => File[$conf_dir],
  }

}