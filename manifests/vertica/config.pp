#
# Class for vertica specific files
#
# === Parameters
#
# [*db_user*]
#   name of the database user
#
# [*db_group*]
#   name of the database group
#
# [*db_admin_password*]
#   database admin password
#
# [*metrics_schema*]
#   location of the metrics schema/projections file
#
# [*mon_api_password*]
#   database api user password
#
# [*mon_persister_password*]
#   database persister user password
#
# [*monitor_password*]
#   database monitor user password
#
class monasca::vertica::config (
  $db_user                = 'dbadmin',
  $db_group               = 'verticadba',
  $db_admin_password      = unset,
  $metrics_schema         = 'puppet:///modules/monasca/vertica/mon_metrics_schema.sql',
  $mon_api_password       = unset,
  $mon_persister_password = unset,
  $monitor_password       = unset,
) {

  $files = 'puppet:///modules/monasca/vertica/'
  $templates = 'monasca/vertica'
  $install_dir = '/var/vertica'
  $alarms_schema = 'mon_alarms_schema.sql'
  $grants_schema = 'mon_grants.sql'
  $config_schema = 'mon_schema.sql'
  $users_schema = 'mon_users.sql'
  $cluster_script = 'create_mon_db_cluster.sh'
  $single_node_script = 'create_mon_db.sh'

  file { $install_dir:
    ensure => directory,
    owner  => $db_user,
    group  => $db_group,
    mode   => '0755',
  }

  file { "${install_dir}/${alarms_schema}":
    ensure  => file,
    source  => "${files}/${alarms_schema}",
    mode    => '0644',
    owner   => $db_user,
    group   => $db_group,
    require => File[$install_dir],
  }

  file { "${install_dir}/${grants_schema}":
    ensure  => file,
    source  => "${files}/${grants_schema}",
    mode    => '0644',
    owner   => $db_user,
    group   => $db_group,
    require => File[$install_dir],
  }

  file { "${install_dir}/mon_metrics_schema.sql":
    ensure  => file,
    source  => $metrics_schema,
    mode    => '0644',
    owner   => $db_user,
    group   => $db_group,
    require => File[$install_dir],
  }

  file { "${install_dir}/${config_schema}":
    ensure  => file,
    content => template("${templates}/${config_schema}.erb"),
    mode    => '0644',
    owner   => $db_user,
    group   => $db_group,
    require => File[$install_dir],
  }

  file { "${install_dir}/${users_schema}":
    ensure  => file,
    content => template("${templates}/${users_schema}.erb"),
    mode    => '0644',
    owner   => $db_user,
    group   => $db_group,
    require => File[$install_dir],
  }

  file { "${install_dir}/${cluster_script}":
    ensure  => file,
    content => template("${templates}/${cluster_script}.erb"),
    mode    => '0755',
    owner   => $db_user,
    group   => $db_group,
    require => File[$install_dir],
  }

  file { "${install_dir}/${single_node_script}":
    ensure  => file,
    content => template("${templates}/${single_node_script}.erb"),
    mode    => '0755',
    owner   => $db_user,
    group   => $db_group,
    require => File[$install_dir],
  }
}
