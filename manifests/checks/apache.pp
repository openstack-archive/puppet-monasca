# == Class: monasca::checks::apache
#
# Sets up the monasca apache check.
#
# === Parameters
#
# [*instances*]
#   A hash of instances for the check.
#   Each instance should be a hash of the check's parameters.
#   Parameters for the apache check are:
#       name (the instance key): The name of the instance.
#       apache_status_url (required)
#       dimensions
#   e.g.
#   instances:
#     server:
#       apache_status_url: 'http://your.server.name/server-status'
#
class monasca::checks::apache(
  $instances = undef,
){
  $conf_dir = $::monasca::agent::conf_dir

  if($instances){
    Concat["${conf_dir}/apache.yaml"] ~> Service['monasca-agent']
    concat { "${conf_dir}/apache.yaml":
      owner   => 'root',
      group   => $::monasca::group,
      mode    => '0640',
      warn    => true,
      require => File[$conf_dir],
    }
    concat::fragment { 'apache_header':
      target  => "${conf_dir}/apache.yaml",
      order   => '0',
      content => "---\ninit_config: null\ninstances:\n",
    }
    create_resources('monasca::checks::instances::apache', $instances)
  }
}
