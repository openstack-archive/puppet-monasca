# == Defined Type: monasca::checks::instances::memory
#
# configure monasca plugin yaml file for memory interfaces
#
# === Parameters:
#
# [*dimensions*]
#   any additional dimensions for the check
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
