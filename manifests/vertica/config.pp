#
# Class for vertica specific files
#
# === Parameters
#
# [*api_pool*]
#   name of the resource pool for monasca api process
#
# [*api_pool_mem_size*]
#   memory size for api resource pool
#
# [*api_pool_max_mem_size*]
#   max memory size for api resource pool
#
# [*api_pool_planned_con*]
#   planned concurrency for api resource pool
#
# [*api_pool_max_con*]
#   max concurrency for api resource pool
#
# [*api_pool_runtime_priority*]
#   runtime priority for api resource pool (LOW, MEDIUM..)
#
# [*api_pool_runtime_priority_thresh*]
#   runtime priority threshold for api resource pool (# of seconds)
#
# [*api_pool_priority*]
#   priority threshold api resource pool
#
# [*api_pool_exec_parallel*]
#   execution parallelism for api resource pool
#
# [*db_admin_password*]
#   database admin password
#
# [*db_group*]
#   name of the database group
#
# [*db_user*]
#   name of the database user
#
# [*metrics_schema*]
#   location of the metrics schema/projections file
#
# [*monitor_password*]
#   database monitor user password
#
# [*monitor_user*]
#   database monitor user name
#
# [*pers_pool*]
#   name of the resource pool for monasca persister process
#
# [*pers_pool_mem_size*]
#   memory size for persister resource pool
#
# [*pers_pool_max_mem_size*]
#   max memory size for persister resource pool
#
# [*pers_pool_planned_con*]
#   planned concurrency for persister resource pool
#
# [*pers_pool_max_con*]
#   max concurrency for persister resource pool
#
# [*pers_pool_runtime_priority*]
#   runtime priority for persister resource pool (LOW, MEDIUM..)
#
# [*pers_pool_runtime_priority_thresh*]
#   runtime priority threshold for persister resource pool (# of seconds)
#
# [*pers_pool_priority*]
#   priority threshold persister resource pool
#
# [*pers_pool_exec_parallel*]
#   execution parallelism for persister resource pool
#
# [*virtual_env*]
#   location of python virtual environment to install to for any
#   python utilities
#
class monasca::vertica::config (
  $api_pool                          = 'api_pool',
  $api_pool_mem_size                 = '5G',
  $api_pool_max_mem_size             = '15G',
  $api_pool_planned_con              = '2',
  $api_pool_max_con                  = '4',
  $api_pool_runtime_priority         = 'MEDIUM',
  $api_pool_runtime_priority_thresh  = '2',
  $api_pool_priority                 = '50',
  $api_pool_exec_parallel            = '2',
  $db_user                           = 'dbadmin',
  $db_group                          = 'verticadba',
  $db_admin_password                 = unset,
  $metrics_schema                    = 'puppet:///modules/monasca/vertica/mon_metrics_schema.sql',
  $monitor_password                  = unset,
  $monitor_user                      = 'monitor',
  $pers_pool                         = 'persister_pool',
  $pers_pool_mem_size                = '5G',
  $pers_pool_max_mem_size            = '15G',
  $pers_pool_planned_con             = '2',
  $pers_pool_max_con                 = '4',
  $pers_pool_runtime_priority        = 'MEDIUM',
  $pers_pool_runtime_priority_thresh = '2',
  $pers_pool_priority                = '60',
  $pers_pool_exec_parallel           = '1',
  $virtual_env                       = '/var/lib/vertica',
) {

  include ::monasca::params

  $api_db_user = $::monasca::params::api_db_user
  $api_db_password = $::monasca::params::api_db_password
  $pers_db_user = $::monasca::params::pers_db_user
  $pers_db_password = $::monasca::params::pers_db_password

  $files = 'puppet:///modules/monasca/vertica/'
  $templates = 'monasca/vertica'
  $install_dir = '/var/vertica'
  $alarms_schema = 'mon_alarms_schema.sql'
  $grants_schema = 'mon_grants.sql'
  $config_schema = 'mon_schema.sql'
  $users_schema = 'mon_users.sql'
  $cluster_script = 'create_mon_db_cluster.sh'
  $single_node_script = 'create_mon_db.sh'
  $prune_script_name = 'prune_vertica.py'
  $prune_script = "${virtual_env}/bin/${prune_script_name}"
  $partition_drop_script_name = 'drop_vertica_partitions.py'
  $partition_drop_script = "${virtual_env}/bin/${partition_drop_script_name}"

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

  file { '/usr/sbin/vsql':
    ensure  => file,
    content => template("${templates}/vsql.erb"),
    mode    => '0755',
    owner   => $db_user,
    group   => $db_group,
    require => File[$install_dir],
  }

  python::virtualenv { $virtual_env :
    owner   => 'root',
    group   => 'root',
    before  => [File[$prune_script], File[$partition_drop_script]],
    require => [Package['virtualenv'],Package['python-dev']],
  }

  file { $prune_script:
    ensure  => file,
    content => template("${templates}/${prune_script_name}.erb"),
    mode    => '0755',
    owner   => $db_user,
    group   => $db_group,
    require => File[$install_dir],
  }

  file { $partition_drop_script:
    ensure  => file,
    content => template("${templates}/${partition_drop_script_name}.erb"),
    mode    => '0755',
    owner   => $db_user,
    group   => $db_group,
    require => File[$install_dir],
  }

  file { '/usr/sbin/update_vertica_stats.sh':
    ensure  => file,
    source  => "${files}/update_vertica_stats.sh",
    mode    => '0755',
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
