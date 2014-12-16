#
# configure monasca plugin yaml file for network interfaces
#
define monasca::checks::instances::network (
  $collect_connection_state = undef,
  $excluded_interfaces      = undef,
  $excluded_interface_re    = undef,
  $dimensions               = undef,
) {
  $conf_dir = $::monasca::agent::conf_dir
  concat::fragment { "${title}_network_instance":
    target  => "${conf_dir}/network.yaml",
    content => template('monasca/checks/network.erb'),
    order   => '1',
  }
}
