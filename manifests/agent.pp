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
  $enabled                = true,
  $url,
  $username,
  $password,
  $keystone_url,
  $service,
  $project_name           = 'services',
  $hostname               = undef,
  $dimensions             = undef,
  $recent_point_threshold = '30',
  $use_mount              = 'no',
  $listen_port            = '17123',
  $non_local_traffic      = 'no',
  $monstatsd_port         = '8125',
  $monstatsd_interval     = '10',
  $monstatsd_normalize    = 'yes',
  $statsd_forward_host    = undef,
  $statsd_forward_port    = '8125',
  $device_blacklist_re    = '.*\/dev\/mapper\/lxc-box.*',
  $log_level              = 'INFO',
  $collector_log_file     = '/var/log/monasca/agent/collector.log',
  $forwarder_log_file     = '/var/log/monasca/agent/forwarder.log',
  $monstatsd_log_file     = '/var/log/monasca/agent/monstatsd.log',
  $log_to_syslog          = 'yes',
  $syslog_host            = undef ,
  $syslog_port            = undef,
  $virtual_env            = '/var/www/monasca-agent',
  $agent_user             = 'monasca-agent',
) {
  include monasca
  include monasca::params

  $agent_dir = "${::monasca::monasca_dir}/agent"
  $additional_checksd = "${agent_dir}/checks.d"
  $conf_dir = "${agent_dir}/conf.d"

  File[$agent_dir] -> Agent_config<||>
  Agent_config<||> ~> Service['monasca-agent']

  if $::monasca::params::agent_package {
    ensure_packages('python-virtualenv')
    ensure_packages('python-dev')

    python::virtualenv { $virtual_env :
      owner   => 'root',
      group   => 'root',
      require => [Package['python-virtualenv'],Package['python-dev']],
      before  => Python::Pip['monasca-agent'],
    }
    python::pip { 'monasca-agent' :
      ensure     => '1.0.14',
      pkgname    => $::monasca::params::agent_package,
      virtualenv => $virtual_env,
      owner      => 'root',
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

  file { $additional_checksd:
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => File[$agent_dir],
    before  => Service['monasca-agent'],
  }

  file { $conf_dir:
    ensure  => 'directory',
    owner   => 'root',
    group   => $::monasca::group,
    mode    => '0755',
    require => File[$agent_dir],
    before  => Service['monasca-agent'],
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

  if $hostname {
    agent_config {
      'Main/hostname' : value => $hostname;
    }
  }
  else {
    agent_config {
      'Main/hostname' : ensure => absent;
    }
  }

  # if $dimensions {
  #   agent_config {
  #     'Main/dimensions' : value => $dimensions;
  #   }
  # }
  # else {
  #   agent_config {
  #     'Main/dimensions' : ensure => absent;
  #   }
  # }

  if $statsd_forward_host {
    agent_config {
      'Main/statsd_forward_host' : value => $statsd_forward_host;
      'Main/statsd_forward_port' : value => $statsd_forward_port;
    }
  }
  else {
    agent_config {
      'Main/statsd_forward_host' : ensure => absent;
      'Main/statsd_forward_port' : ensure => absent;
    }
  }

  if $syslog_host and $syslog_port {
    agent_config {
      'Main/syslog_host' : value => $syslog_host;
      'Main/syslog_port' : value => $syslog_port;
    }
  }
  else {
    agent_config {
      'Main/syslog_host' : ensure => absent;
      'Main/syslog_port' : ensure => absent;
    }
  }

  agent_config {
    'Api/url':                     value => $url;
    'Api/username':                value => $username;
    'Api/password':                value => $password;
    'Api/keystone_url':            value => $keystone_url;
    'Api/project_name':            value => $project_name;
    'Main/recent_point_threshold': value => $recent_point_threshold;
    'Main/use_mount':              value => $use_mount;
    'Main/listen_port':            value => $listen_port;
    'Main/additional_checksd':     value => $additional_checksd;
    'Main/non_local_traffic':      value => $non_local_traffic;
    'Main/monstatsd_port':         value => $monstatsd_port;
    'Main/monstatsd_interval':     value => $monstatsd_interval;
    'Main/monstatsd_normalize':    value => $monstatsd_normalize;
    'Main/device_blacklist_re':    value => $device_blacklist_re;
    'Main/log_level':              value => $log_level;
    'Main/collector_log_file':     value => $collector_log_file;
    'Main/forwarder_log_file':     value => $forwarder_log_file;
    'Main/monstatsd_log_file':     value => $monstatsd_log_file;
    'Main/log_to_syslog':          value => $log_to_syslog;
    'Main/dimensions':             value => "service:${service}"
  }
}
