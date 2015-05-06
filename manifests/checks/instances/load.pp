#
# configure monasca plugin yaml file for load interfaces
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
