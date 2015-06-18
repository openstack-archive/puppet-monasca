# == Class: monasca::checks::disk
#
# Sets up the monasca disk check.
#
# === Parameters
#
# [*instances*]
#   A hash of instances for the check.
#   Each instance should be a hash of the check's parameters.
#   Parameters for the disk check are:
#       name (the instance key): The name of the instance.
#       use_mount (default = True)
#       send_io_stats (default = True)
#       send_rollup_stats (default = False)
#       device_blacklist_re
#       ignore_filesystem_types
#       dimensions
#   e.g.
#   instances:
#     disk_stats:
#       dimensions:
#
class monasca::checks::disk(
  $instances = undef,
){
  $conf_dir = $::monasca::agent::conf_dir

  if($instances){
    Concat["${conf_dir}/disk.yaml"] ~> Service['monasca-agent']
    concat { "${conf_dir}/disk.yaml":
      owner   => 'root',
      group   => $::monasca::group,
      mode    => '0640',
      warn    => true,
      require => File[$conf_dir],
    }
    concat::fragment { 'disk_header':
      target  => "${conf_dir}/disk.yaml",
      order   => '0',
      content => "---\ninit_config: null\ninstances:\n",
    }
    create_resources('monasca::checks::instances::disk', $instances)
  }
}
