# == Class: monasca::checks::mysql
#
# Sets up the monasca mysql check.
# Requires MySQL-python
#
# === Parameters
#
# [*instances*]
#   A hash of instances for the check.
#   Each instance should be a hash of the check's parameters.
#   Parameters for the mysql check are:
#       name (the instance key): The name of the instance.
#       server
#       user
#       port
#       pass
#       sock
#       defaults_file
#       dimensions
#       options
#   e.g.
#   instances:
#     local:
#       defaults_file: '/root/.my.cnf'
#       server: 'localhost'
#       user: 'root'
#
class monasca::checks::mysql(
  $instances = undef,
){
  $conf_dir = $::monasca::agent::conf_dir

  if($instances){
    Concat["${conf_dir}/mysql.yaml"] ~> Service['monasca-agent']
    concat { "${conf_dir}/mysql.yaml":
      owner   => 'root',
      group   => $::monasca::group,
      mode    => '0640',
      warn    => true,
      require => File[$conf_dir],
    }
    concat::fragment { 'mysql_header':
      target  => "${conf_dir}/mysql.yaml",
      order   => '0',
      content => "---\ninit_config: null\ninstances:\n",
    }
    create_resources('monasca::checks::instances::mysql', $instances)
  }
}
