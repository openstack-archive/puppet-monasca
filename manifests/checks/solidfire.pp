# == Class: monasca::checks::solidfire
#
# Sets up the monasca solidfire agent plugin.
#
# === Parameters
#
# [*instances*]
#   (Required) A hash of instances for the solidfire plugin. Each instance
#   should be a hash of the check's parameters. Parameters for the solidfire
#   check are (all required):
#
#       cluster_name (the instance key): The name of the cluster.
#       admin_name: Name of the cluster administrator.
#       admin_password: Password of the cluster administrator.
#       cluster_mvip: Management VIP of the cluster.
#
#   Example:
#
#     instances:
#       rack_d_cluster:
#         admin_name: monasca_admin
#         admin_password: secret_password
#         cluster_mvip: 192.168.1.1
#
class monasca::checks::solidfire(
  $instances,
){
  $conf_dir = $::monasca::agent::conf_dir

  if($instances){
    Concat["${conf_dir}/solidfire.yaml"] ~> Service['monasca-agent']
    concat { "${conf_dir}/solidfire.yaml":
      owner   => 'root',
      group   => $::monasca::group,
      mode    => '0640',
      warn    => true,
      require => File[$conf_dir],
    }
    concat::fragment { 'solidfire_header':
      target  => "${conf_dir}/solidfire.yaml",
      order   => '0',
      content => "---\ninit_config: null\ninstances:\n",
    }
    create_resources('monasca::checks::instances::solidfire', $instances)
  }
}
