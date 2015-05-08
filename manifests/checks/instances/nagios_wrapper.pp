#
# configure monasca plugin yaml file for nagios_wrapper
#
# nrpe is not used by the check, only by puppet to determine which host
# uses this fragment
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
