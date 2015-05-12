# == Class: monasca::agents
#
# Setups monasca agent.
#
# === Parameters
#
# [*enabled*]
#   TODO:add comments here.
#
class monasca::agent(
  $enabled                 = true,
  $url,
  $username,
  $password,
  $keystone_url,
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
  $agent_user              = 'monasca-agent',
  $agent_ensure            = 'latest',
  $install_python_deps     = true,
  $python_dep_ensure       = 'present',
  $pip_install_args        = '',
) {
  include monasca
  include monasca::params

  $agent_dir = "${::monasca::monasca_dir}/agent"
  $additional_checksd = "${agent_dir}/checks.d"
  $conf_dir = "${agent_dir}/conf.d"

  if $::monasca::params::agent_package {
    if $install_python_deps {
      package { ['python-virtualenv', 'python-dev']:
        ensure => $python_dep_ensure,
        before => Python::Virtualenv[$virtual_env],
      }
    }

    python::virtualenv { $virtual_env :
      owner   => 'root',
      group   => 'root',
      require => [Package['python-virtualenv'],Package['python-dev']],
      before  => Python::Pip['monasca-agent'],
    }
    python::pip { 'monasca-agent' :
      ensure       => $agent_ensure,
      pkgname      => $::monasca::params::agent_package,
      virtualenv   => $virtual_env,
      owner        => 'root',
      install_args => $pip_install_args,
    }
  }

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
    require => Python::Pip['monasca-agent'],
    before  => Service['monasca-agent'],
  }

  file { "${virtual_env}/share/monasca/agent/supervisor.conf":
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('monasca/supervisor.conf.erb'),
    require => Python::Pip['monasca-agent'],
    before  => Service['monasca-agent'],
  }

  if $enabled {
    $ensure = 'running'
  } else {
    $ensure = 'stopped'
  }

  service { 'monasca-agent':
    ensure => $ensure,
    name   => $::monasca::params::agent_service,
  }
}
