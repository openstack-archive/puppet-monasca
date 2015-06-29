# == Defined Type: monasca::checks::instances::disk
#
# configure monasca plugin yaml file for disk interfaces
#
# === Parameters:
#
# [*use_mount*]
#   flag for mount setting for the check
#
# [*send_io_stats*]
#   flag for whether or not to send io statistics
#
# [*send_rollup_stats*]
#   flag for whether or not to send rollup statistics
#
# [*device_blacklist_re*]
#   regular expression for devices to ignore
#
# [*ignore_filesystem_types*]
#   types of file systems to ignore
#
# [*dimensions*]
#   any additional dimensions for the check
#
define monasca::checks::instances::disk (
  $use_mount               = undef,
  $send_io_stats           = undef,
  $send_rollup_stats       = undef,
  $device_blacklist_re     = undef,
  $ignore_filesystem_types = undef,
  $dimensions              = undef,
) {
  $conf_dir = $::monasca::agent::conf_dir
  concat::fragment { "${title}_disk_instance":
    target  => "${conf_dir}/disk.yaml",
    content => template('monasca/checks/disk.erb'),
    order   => '1',
  }
}
