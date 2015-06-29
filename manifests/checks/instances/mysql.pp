# == Defined Type: monasca::checks::instances::mysql
#
# configure monasca plugin yaml file for mysql
#
# === Parameters:
#
# [*server*]
#   mysql server to gather stats from
#
# [*user*]
#   mysql user
#
# [*port*]
#   mysql port
#
# [*pass*]
#   mysql password
#
# [*sock*]
#   mysql socket
#
# [*defaults_file*]
#   file containing any default mysql settings
#
# [*dimensions*]
#   any additional dimensions for the check
#
# [*options*]
#   any additional options for the check
#
define monasca::checks::instances::mysql (
  $server        = undef,
  $user          = undef,
  $port          = undef,
  $pass          = undef,
  $sock          = undef,
  $defaults_file = undef,
  $dimensions    = undef,
  $options       = undef,
) {
  $conf_dir = $::monasca::agent::conf_dir
  concat::fragment { "${title}_mysql_instance":
    target  => "${conf_dir}/mysql.yaml",
    content => template('monasca/checks/mysql.erb'),
    order   => '1',
  }
}
