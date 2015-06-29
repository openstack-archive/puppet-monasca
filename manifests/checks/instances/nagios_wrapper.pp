# == Defined Type: monasca::checks::instances::nagios_wrapper
#
# configure monasca plugin yaml file for nagios_wrapper
#
# === Parameters:
#
# nrpe is not used by the check, only by puppet to determine which host
# uses this fragment
#
# [*check_command*]
#   command to execute for the nagios check
#
# [*check_name*]
#   name of the nagios check
#
# [*host_name*]
#   host name being checked
#
# [*check_interval*]
#   how frequently (in seconds) the check should be run
#
# [*dimensions*]
#   any additional dimensions for the check
#
# [*nrpe*]
#   flag indicating if this is an nrpe check
#
define monasca::checks::instances::nagios_wrapper (
  $check_command,
  $check_name     = undef,
  $host_name      = undef,
  $check_interval = undef,
  $dimensions     = undef,
  $nrpe           = undef,
) {
  $conf_dir = $::monasca::agent::conf_dir
  concat::fragment { "${title}_nagios_wrapper_instance":
    target  => "${conf_dir}/nagios_wrapper.yaml",
    content => template('monasca/checks/nagios_wrapper.erb'),
    order   => '1',
  }
}
