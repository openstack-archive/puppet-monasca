# == Defined Type: monasca::checks::instances::network
#
# configure monasca plugin yaml file for network interfaces
#
# === Parameters:
#
# [*collect_connection_state*]
#   flag to indicate if connection state should be collected
#
# [*excluded_interfaces*]
#   explicit list of interfaces to be ignored
#
# [*excluded_interface_re*]
#   regular expression for interfaces to be ignored
#
# [*use_bits*]
#   submits metrics in bits rather than bytes
#
# [*dimensions*]
#   any additional dimensions for the check
#
define monasca::checks::instances::network (
  $collect_connection_state = undef,
  $excluded_interfaces      = undef,
  $excluded_interface_re    = undef,
  $use_bits                 = undef,
  $dimensions               = undef,
) {
  $conf_dir = $::monasca::agent::conf_dir
  concat::fragment { "${title}_network_instance":
    target  => "${conf_dir}/network.yaml",
    content => template('monasca/checks/network.erb'),
    order   => '1',
  }
}
