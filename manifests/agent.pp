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
  $service,
  $project_name            = 'services',
  $hostname                = undef,
  $dimensions              = 'None',
  $ca_file                 = undef,
  $max_buffer_size         = '1000',
  $backlog_send_rate       = '1000',
  $amplifier               = '0',
  $recent_point_threshold  = '30',
  $use_mount               = 'no',
  $listen_port             = '17123',
  $non_local_traffic       = 'no',
  $system_metrics          = 'cpu,disk,io,load,memory',
  $device_blacklist_re     = '.*\/dev\/mapper\/lxc-box.*',
  $ignore_filesystem_types = 'tmpfs,devtmpfs',
  $statsd_port             = '8125',
  $statsd_interval         = '10',
  $statsd_normalize        = 'yes',
  $statsd_forward_host     = undef,
  $statsd_forward_port     = '8125',

  $log_level               = 'INFO',
  $collector_log_file      = '/var/log/monasca/agent/collector.log',
  $forwarder_log_file      = '/var/log/monasca/agent/forwarder.log',
  $monstatsd_log_file      = '/var/log/monasca/agent/monstatsd.log',
  $log_to_syslog           = 'yes',
  $syslog_host             = undef ,
  $syslog_port             = undef,
  $virtual_env             = '/var/www/monasca-agent',
  $agent_user              = 'monasca-agent',
  $agent_version           = 'latest',
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
      ensure     => $agent_version,
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

  if $ca_file {
    agent_config {
      'Api/insecure' : value => false;
      'Api/ca_file'  : value => $ca_file;
    }
  }
  else {
    agent_config {
      'Api/insecure' : value  => true;
      'Api/ca_file'  : ensure => absent;
    }
  }

  if $statsd_forward_host {
    agent_config {
      'Statsd/monasca_statsd_forward_host'        : value => $statsd_forward_host;
      'Statsd/monasca_statsd_statsd_forward_port' : value => $statsd_forward_port;
    }
  }
  else {
    agent_config {
      'Statsd/monasca_statsd_forward_host'        : ensure => absent;
      'Statsd/monasca_statsd_statsd_forward_port' : ensure => absent;
    }
  }

  if $syslog_host and $syslog_port {
    agent_config {
      'Logging/syslog_host' : value => $syslog_host;
      'Logging/syslog_port' : value => $syslog_port;
    }
  }
  else {
    agent_config {
      'Logging/syslog_host' : ensure => absent;
      'Logging/syslog_port' : ensure => absent;
    }
  }

  agent_config {
    'Api/url':                         value => $url;
    'Api/username':                    value => $username;
    'Api/password':                    value => $password;
    'Api/keystone_url':                value => $keystone_url;
    'Api/project_name':                value => $project_name;
    'Api/max_buffer_size':             value => $max_buffer_size;
    'Api/backlog_send_rate':           value => $backlog_send_rate;
    'Api/amplifier':                   value => $amplifier;
    'Main/dimensions' :                value => $dimensions;
    'Main/recent_point_threshold':     value => $recent_point_threshold;
    'Main/use_mount':                  value => $use_mount;
    'Main/listen_port':                value => $listen_port;
    'Main/additional_checksd':         value => $additional_checksd;
    'Main/non_local_traffic':          value => $non_local_traffic;
    'Main/system_metrics':             value => $system_metrics;
    'Main/device_blacklist_re':        value => $device_blacklist_re;
    'Main/ignore_filesystem_types':    value => $ignore_filesystem_types;
    'Statsd/monasca_statsd_port':      value => $statsd_port;
    'Statsd/monasca_statsd_interval':  value => $statsd_interval;
    'Statsd/monasca_statsd_normalize': value => $statsd_normalize;
    'Logging/log_level':               value => $log_level;
    'Logging/collector_log_file':      value => $collector_log_file;
    'Logging/forwarder_log_file':      value => $forwarder_log_file;
    'Logging/monstatsd_log_file':      value => $monstatsd_log_file;
    'Logging/log_to_syslog':           value => $log_to_syslog;
  }
}
