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
# [*checks*]
#   A hash of check defenitions.
#   For use with types and nodes.  When all three are defined they will combined to create a list
#        of checks in the format that the nagios plugin requires, and merged with the instances list
#   Parameters are:
#       check_name (the instance key): The name of the check.
#       check_command (required): Use 'host' where the name of the host should be filled in.
#       check_interval
#       dimensions
# [*types*]
#   A hash of node type defenitions.
#   For use with checks and nodes
#   Parameters are:
#       type_name (the instance key): The type of node (e.g control, compute).
#       This is followed with a list of checks to run on that node type.
# [*nodes*]
#   A hash of node defenitions.
#   For use with checks and types
#   Parameters are:
#       node_name (the instance key): The hostname of the node
#       type (required): The type of given node.
#       dimensions
#
class monasca::checks::nagios_wrapper(
  $check_path     = '/usr/lib/nagios/plugins:/usr/local/bin/nagios',
  $temp_file_path = '/dev/shm/',
  $instances      = undef,
  $checks         = undef,
  $types          = undef,
  $nodes          = undef,
){
  $conf_dir = $::monasca::agent::conf_dir

  if $checks and $types and $nodes {
    $real_instances = generate_nagios_instances($checks, $types, $nodes, $instances)
  }
  else {
    $real_instances = $instances
  }

  if($real_instances){
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
    create_resources('monasca::checks::instances::nagios_wrapper', $real_instances)
  }
}