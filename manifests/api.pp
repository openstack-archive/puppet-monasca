#
# Class to setup monasca api
#
class monasca::api (
  $blobmirror           = undef,
  $mon_api_build_ver    = undef,
  $mon_api_deb          = undef,
  $kafka_brokers        = undef,
  $keystone_endpoint    = undef,
  $keystone_admin_token = undef,
  $api_user             = 'monasca_api',
  $zookeeper_servers    = undef,
) {
  include monasca
  include monasca::params

  $api_fetch_url = "http://${blobmirror}/repos/monasca/monasca_api"
  $latest_api_deb = "/tmp/${mon_api_deb}"
  $api_cfg_file = '/etc/monasca/api-config.yml'
  $stack_script_src = 'puppet:///modules/monasca/monasca_stack.sh'
  $stack_script = '/usr/bin/monasca_stack.sh'

  wget::fetch { "${api_fetch_url}/${mon_api_build_ver}/${mon_api_deb}":
    destination => $latest_api_deb,
    timeout     => 300,
    before      => [Package['install-api'],File[$latest_api_deb]],
  }

  user { $api_user:
    ensure  => present,
    groups  => $::monasca::group,
    require => Group[$::monasca::group],
  }

  file { $latest_api_deb:
    ensure => present,
  }

  package { 'monasca-api':
    ensure   => latest,
    provider => dpkg,
    source   => $latest_api_deb,
    alias    => 'install-api',
  }

  #Variables for the template
  $admin_password = $::monasca::params::admin_password
  $admin_name = $::monasca::params::admin_name
  $auth_method = $::monasca::params::auth_method
  $sql_host = $::monasca::params::sql_host
  $sql_user = $::monasca::params::sql_user
  $sql_password = $::monasca::params::sql_password
  $region_name = $::monasca::params::region
  $monasca_api_port = $::monasca::params::port
  $api_db_user = $::monasca::params::api_db_user
  $api_db_password = $::monasca::params::api_db_password

  file { $api_cfg_file:
    ensure  => file,
    content => template('monasca/api-config.yml.erb'),
    mode    => '0644',
    owner   => $api_user,
    group   => $::monasca::group,
    require => [User[$api_user], Group[$::monasca::group], File[$::monasca::log_dir]],
  } ~> Service['monasca-api']

  service { 'monasca-api':
    ensure  => running,
    require => [File[$api_cfg_file],File[$latest_api_deb],Package['install-api']],
  }

  # Remove any old debs (puppet won't delete current resources)
  tidy { '/tmp':
    matches => 'monasca*.deb',
    recurse => true,
  }

  file { $stack_script:
    ensure => file,
    source => $stack_script_src,
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
  }
}
