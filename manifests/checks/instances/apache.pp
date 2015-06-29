# == Defined Type: monasca::checks::instances::apache
#
# configure monasca plugin yaml file for apache
#
# === Parameters:
#
# [*apache_status_url*]
#   url to get apache status from
#
# [*dimensions*]
#   any additional dimensions for the check
#
define monasca::checks::instances::apache (
  $apache_status_url,
  $dimensions = undef,
) {
  $conf_dir = $::monasca::agent::conf_dir
  concat::fragment { "${title}_apache_instance":
    target  => "${conf_dir}/apache.yaml",
    content => template('monasca/checks/apache.erb'),
    order   => '1',
  }
}
