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
#   A hash of instances for the check.
#   Each instance should be a hash of the check's parameters.
#   Parameters for the nagios_wrapper check are:
#       service_name (the instance key): The name of the instance.
#       check_command (required)
#       host_name
#       check_interval
#       dimensions
#   e.g.
#   instances:
#     load:
#       check_command: 'check_load -r -w 2,1.5,1 -c 10,5,4'
#     disk:
#       check_command: 'check_disk -w 15\% -c 5\% -A -i /srv/node'
#       check_interval: '300'
# [*host_name*]
#   Use with the collector to determine which checks run on which host
# [*central_mon*]
#   Set to true when using the collector if a single host will be running
#   all non-nrpe checks
#
class monasca::checks::nagios_wrapper(
  $check_path     = '/usr/lib/nagios/plugins:/usr/local/bin/nagios',
  $temp_file_path = '/dev/shm/',
  $instances      = undef,
  $host_name      = undef,
  $central_mon    = false,
){
  $conf_dir = $::monasca::agent::conf_dir

  if ($central_mon) {
    Monasca::Checks::Instances::Nagios_wrapper <<| nrpe == false |>>
  }
  else {
    Monasca::Checks::Instances::Nagios_wrapper <<| host_name == $host_name and nrpe != false |>>
  }

  Concat["${conf_dir}/nagios_wrapper.yaml"] ~> Service['monasca-agent']
  concat { "${conf_dir}/nagios_wrapper.yaml":
    owner   => 'root',
    group   => $::monasca::group,
    mode    => '0640',
    warn    => true,
    require => File[$conf_dir],
  }
  concat::fragment { 'nagios_wrapper_header':
    target  => "${conf_dir}/nagios_wrapper.yaml",
    order   => '0',
    content => template('monasca/checks/nagios_wrapper.yaml.erb'),
  }
  if($instances){
    create_resources('monasca::checks::instances::nagios_wrapper', $instances)
  }
}
