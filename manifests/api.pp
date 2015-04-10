#
# Class to setup monasca api
#
class monasca::api (
  $api_user             = 'monasca_api',
  $blobmirror           = undef,
  $gzip_setting         = true,
  $kafka_brokers        = undef,
  $keystone_endpoint    = undef,
  $keystone_admin_token = undef,
  $mon_api_build_ver    = undef,
  $mon_api_deb          = undef,
  $region_name          = 'NA',
  $zookeeper_servers    = undef,
) {
  include monasca
  include monasca::params

  $api_fetch_url = "http://${blobmirror}/repos/monasca/monasca_api"
  $latest_api_deb = "/tmp/${mon_api_deb}"
  $api_cfg_file = '/etc/monasca/api-config.yml'
  $stack_script_src = 'puppet:///modules/monasca/monasca_stack.sh'
  $stack_script = '/usr/bin/monasca_stack.sh'
  $startup_script = '/etc/init/monasca-api.conf'
  $startup_script_src = 'puppet:///modules/monasca/monasca-api.conf'

  wget::fetch { "${api_fetch_url}/${mon_api_build_ver}/${mon_api_deb}":
    destination => $latest_api_deb,
    timeout     => 300,
    before      => [Package['install-api'],File[$latest_api_deb]],
  } ~> Service['monasca-api']

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
    require => [File[$api_cfg_file],
                File[$latest_api_deb],
                File[$startup_script],
                Package['install-api']],
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

  file { $startup_script:
    ensure => file,
    source => $startup_script_src,
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
  }
}
