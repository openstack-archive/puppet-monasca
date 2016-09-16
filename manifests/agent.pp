# == Class: monasca::agents
#
# Setups monasca agent.
#
# === Parameters
#
# [*url*]
#   url of the monasca api server to POST metrics to
#
# [*username*]
#   monasca agent name
#
# [*password*]
#   monasca agent password
#
# [*keystone_url*]
#   keystone endpoint for authentication
#
# [*enabled*]
#   flag to enable/disable the monasca agent
#
# [*project_name*]
#   name of keystone project to POST metrics for
#
# [*project_domain_id*]
#   domain id of the keystone project to POST metrics for
#
# [*project_domain_name*]
#   domain name of the keystone project to POST metrics for
#
# [*project_id*]
#   id of keystone project to POST metrics for
#
# [*ca_file*]
#   certificate file to use in keystone authentication
#
# [*max_buffer_size*]
#   buffer size for metrics POSTing
#
# [*backlog_send_rate*]
#   how name metrics to POST from backlog at a time
#
# [*amplifier*]
#   multiplier for testing, allows POSTing the same metric multiple times
#
# [*hostname*]
#   hostname for this monasca agent
#
# [*dimensions*]
#   list of dimensions for this monasca agent
#
# [*recent_point_threshold*]
#   number of seconds to consider a metric 'recent'
#
# [*check_freq*]
#   how frequently (in seconds) to run the agent
#
# [*listen_port*]
#   port for the monasca agent to listen on
#
# [*non_local_traffic*]
#   flag for whether or not to support non-local traffic
#   (see monasca documentation for more details)
#
# [*statsd_port*]
#   port for the statsd server
#
# [*statsd_interval*]
#   frequency to poll statsd
#
# [*statsd_forward_host*]
#   host for statsd server
#
# [*statsd_forward_port*]
#   port for statsd server
#
# [*log_level*]
#   logging level -- INFO, DEBUG, ALL...
#
# [*collector_log_file*]
#   logfile for monasca collector
#
# [*forwarder_log_file*]
#   logfile for monasca forwarder
#
# [*monstatsd_log_file*]
#   logfile for monasca statsd collector
#
# [*log_to_syslog*]
#   flag for whether or not to log to syslog
#
# [*syslog_host*]
#   host of the syslog server
#
# [*syslog_port*]
#   port of the syslog server
#
# [*virtual_env*]
#   path of python virtual environment symlink
#
# [*virtual_env_dir*]
#   directory for python virtual environments
#
# [*virtual_env_reqs*]
#   requirements file for the agent venv
#
# [*virtual_envs*]
#   a hash of virtual envs to build
#
# [*agent_user*]
#   name of the monasca agent user
#
# [*install_python_deps*]
#   flag for whether or not to install python dependencies
#
# [*python_dep_ensure*]
#   flag for whether or not to ensure/update python dependencies
#
# [*pip_install_args*]
#   arguments to pass to the pip install command
#
class monasca::agent(
  $url,
  $username,
  $password,
  $keystone_url,
  $enabled                 = true,
  $project_name            = 'null',
  $project_domain_id       = 'null',
  $project_domain_name     = 'null',
  $project_id              = 'null',
  $ca_file                 = undef,
  $max_buffer_size         = '1000',
  $backlog_send_rate       = '1000',
  $amplifier               = '0',
  $hostname                = undef,
  $dimensions              = {},
  $recent_point_threshold  = '30',
  $check_freq              = '15',
  $listen_port             = '17123',
  $non_local_traffic       = false,
  $statsd_port             = '8125',
  $statsd_interval         = '10',
  $statsd_forward_host     = undef,
  $statsd_forward_port     = '8125',
  $log_level               = 'INFO',
  $collector_log_file      = '/var/log/monasca/agent/collector.log',
  $forwarder_log_file      = '/var/log/monasca/agent/forwarder.log',
  $monstatsd_log_file      = '/var/log/monasca/agent/monstatsd.log',
  $log_to_syslog           = false,
  $syslog_host             = undef ,
  $syslog_port             = undef,
  $virtual_env             = '/var/lib/monasca-agent',
  $virtual_env_dir         = '/var/lib/monasca-agent-venvs',
  $virtual_env_reqs        = 'puppet:///modules/monasca/agent_requirements.txt',
  $virtual_envs            = {'default'=> {'venv_active'=> true}},
  $agent_user              = 'monasca-agent',
  $install_python_deps     = true,
  $python_dep_ensure       = 'present',
  $pip_install_args        = '',
) {
  include ::monasca
  include ::monasca::params

  $agent_dir = "${::monasca::monasca_dir}/agent"
  $additional_checksd = "${agent_dir}/checks.d"
  $conf_dir = "${agent_dir}/conf.d"

  if $install_python_deps {
    package { ['python-virtualenv', 'python-dev']:
      ensure => $python_dep_ensure,
    }
  }

  file { $virtual_env_dir:
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }
  $defaults = {
    symlink           => $virtual_env,
    basedir           => $virtual_env_dir,
    venv_extra_args   => $pip_install_args,
    venv_requirements => $virtual_env_reqs,
  }
  create_resources('::monasca::virtualenv::agent_instance', $virtual_envs,
    $defaults)

  user { $agent_user:
    ensure  => present,
    groups  => $::monasca::group,
    require => Group[$::monasca::group]
  }

  file{ "${::monasca::log_dir}/agent":
    ensure  => 'directory',
    owner   => $agent_user,
    group   => $::monasca::group,
    mode    => '0755',
    require => File[$::monasca::log_dir],
    before  => Service['monasca-agent'],
  }

  file { $agent_dir:
    ensure  => 'directory',
    owner   => 'root',
    group   => $::monasca::group,
    mode    => '0755',
    require => File[$::monasca::monasca_dir],
  }

  file { "${agent_dir}/agent.yaml":
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('monasca/agent.yaml.erb'),
    require => File[$agent_dir],
    before  => Service['monasca-agent'],
  } ~> Service['monasca-agent']

  file { $additional_checksd:
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => File[$agent_dir],
    before  => Service['monasca-agent'],
    # ensure removal of all checks unmanaged by puppet
    purge   => true,
    force   => true,
    recurse => true,
  }

  file { $conf_dir:
    ensure  => 'directory',
    owner   => 'root',
    group   => $::monasca::group,
    mode    => '0755',
    require => File[$agent_dir],
    before  => Service['monasca-agent'],
    # ensure removal of all checks unmanaged by puppet
    purge   => true,
    force   => true,
    recurse => true,
  }

  file { '/etc/init.d/monasca-agent':
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('monasca/monasca-agent.init.erb'),
    before  => Service['monasca-agent'],
  }

  $log_dir = "${::monasca::log_dir}/agent"
  file { "${agent_dir}/supervisor.conf":
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('monasca/supervisor.conf.erb'),
    notify  => Service['monasca-agent'],
  }

  if $enabled {
    $ensure = 'running'
  } else {
    $ensure = 'stopped'
  }

  service { 'monasca-agent':
    ensure => $ensure,
    enable => $enabled,
    name   => $::monasca::params::agent_service,
  }
}
