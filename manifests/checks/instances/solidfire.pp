# == Defined Type: monasca::checks::instances::solidfire
#
# Configure monasca plugin yaml file for solidfire.
#
# === Parameters:
#
# [*admin_name*]
#   (Required) Name of the cluster administrator.
#
# [*admin_password*]
#   (Required) Password of the cluster administrator.
#
# [*cluster_mvip*]
#   (Required) Management VIP of the cluster.
#
define monasca::checks::instances::solidfire (
  $admin_name,
  $admin_password,
  $cluster_mvip,
) {
  $conf_dir = $::monasca::agent::conf_dir
  concat::fragment { "${title}_solidfire_instance":
    target  => "${conf_dir}/solidfire.yaml",
    content => template('monasca/checks/solidfire.erb'),
    order   => '1',
  }
}
