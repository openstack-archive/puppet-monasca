# == Class: monasca::checks::nagios_wrapper
#
# Sets up the monasca nagios_wrapper check.
#
# === Parameters
# [*check_path*]
#   Directories where Nagios checks (scripts, programs) may live
# [*temp_file_path*]
#   Where to store last-run timestamps for each check
# [*instances*]
#   An array of instances for the check.
#   Each instance should be a hash of the check's parameters.
#   Parameters for the nagios_wrapper check are:
#       name (required)
#       check_command (required)
#       host_name
#       check_interval
#       dimensions
#   e.g.
#   $instances = [{service_name => 'load',
#                  check_command => 'check_load -r -w 2,1.5,1 -c 10,5,4'},
#                 {service_name => 'disk',
#                  check_command => 'check_disk -w 15\% -c 5\% -A -i /srv/node',
#                  check_interval => '300'}]
#
class monasca::checks::nagios_wrapper(
  $check_path     = '/usr/lib/nagios/plugins:/usr/local/bin/nagios',
  $temp_file_path = '/dev/shm/',
  $instances      = [],
){
  $conf_dir = $::monasca::agent::conf_dir

  File["${conf_dir}/nagios_wrapper.yaml"] ~> Service['monasca-agent']
  
  file { "${conf_dir}/nagios_wrapper.yaml":
    owner   => 'root',
    group   => $::monasca::group,
    mode    => '0640',
    content => template('monasca/checks/nagios_wrapper.yaml.erb'),
    require => File[$conf_dir],
  }

}