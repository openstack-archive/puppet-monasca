# == Defined Type: monasca::checks::instances::load
#
# configure monasca plugin yaml file for load interfaces
#
# === Parameters:
#
# [*dimensions*]
#   any additional dimensions for the check
#
define monasca::checks::instances::load (
  $dimensions = undef,
) {
  $conf_dir = $::monasca::agent::conf_dir
  concat::fragment { "${title}_load_instance":
    target  => "${conf_dir}/load.yaml",
    content => template('monasca/checks/load.erb'),
    order   => '1',
  }
}
