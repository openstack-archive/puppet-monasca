#
# configure monasca plugin yaml file for memory interfaces
#
define monasca::checks::instances::memory (
  $dimensions = undef,
) {
  $conf_dir = $::monasca::agent::conf_dir
  concat::fragment { "${title}_memory_instance":
    target  => "${conf_dir}/memory.yaml",
    content => template('monasca/checks/memory.erb'),
    order   => '1',
  }
}
