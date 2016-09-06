# == Class: monasca::checks::vertica
#
# Sets up the monasca agent vertica plugin/check.
#
# === Parameters
#
# [*node_name*]
#   (Required) Vertica node name for this node (example: 'v_mon_node0001').
#
# [*password*]
#   (Required) Password for the vertica user.
#
# [*user*]
#   (Required) Name of the vertica user.
#
# [*service*]
#   (Optional) Name of service dimension for vertica metrics.
#   Defaults to 'vertica'.
#
# [*timeout*]
#   (Optional) Timeout in seconds for how long to wait for a query.
#   Defaults to 3 seconds.
#
class monasca::checks::vertica(
  $node_name,
  $password,
  $user,
  $service   = 'vertica',
  $timeout   = 3,
){
  $conf_dir = $::monasca::agent::conf_dir

  File["${conf_dir}/vertica.yaml"] ~> Service['monasca-agent']

  file { "${conf_dir}/vertica.yaml":
    owner   => 'root',
    group   => $::monasca::group,
    mode    => '0640',
    content => template('monasca/checks/vertica.yaml.erb'),
    require => File[$conf_dir],
  }
}
