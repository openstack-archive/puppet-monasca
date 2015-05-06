#
# configure monasca plugin yaml file for disk interfaces
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
