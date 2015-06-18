# == Class: monasca::checks::zk
#
# Sets up the monasca zookeeper check.
#
# === Parameters
#
# [*instances*]
#   A hash of instances for the check.
#   Each instance should be a hash of the check's parameters.
#   Parameters for the zk check are:
#       name (the instance key): The name of the instance.
#       host (default = localhost)
#       port (default = 2181)
#       timeout (default = 3.0)
#       dimensions
#   e.g.
#   instances:
#     local:
#       host: 'localhost'
#       port: '2181'
#       timeout: '3'
#
class monasca::checks::zk(
  $instances = undef,
){
  $conf_dir = $::monasca::agent::conf_dir

  if($instances){
    Concat["${conf_dir}/zk.yaml"] ~> Service['monasca-agent']
    concat { "${conf_dir}/zk.yaml":
      owner   => 'root',
      group   => $::monasca::group,
      mode    => '0640',
      warn    => true,
      require => File[$conf_dir],
    }
    concat::fragment { 'zk_header':
      target  => "${conf_dir}/zk.yaml",
      order   => '0',
      content => "---\ninit_config: null\ninstances:\n",
    }
    create_resources('monasca::checks::instances::zk', $instances)
  }
}
