# == Defined Type: monasca::checks::instances::process
#
# configure monasca plugin yaml file for process usage
#
# === Parameters:
#
# [*search_string*]
#   process search string to include in the check
#
# [*exact_match*]
#   flag if the search_string needs to be an exact match
#
# [*cpu_check_interval*]
#   how frequently (in seconds) the check should run
#
# [*dimensions*]
#   any additional dimensions for the check
#
define monasca::checks::instances::process (
  $search_string,
  $exact_match        = undef,
  $cpu_check_interval = undef,
  $dimensions         = undef,
) {
  $conf_dir = $::monasca::agent::conf_dir
  concat::fragment { "${title}_process_instance":
    target  => "${conf_dir}/process.yaml",
    content => template('monasca/checks/process.erb'),
    order   => '1',
  }
}

