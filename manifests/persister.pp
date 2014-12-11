#
# Class to setup monasca persister
#
class monasca::persister (
  $blobmirror         = undef,
  $mon_pers_build_ver = undef,
  $mon_pers_deb       = undef,
  $pers_user          = 'persister',
  $pers_db_user       = 'mon_persister',
  $zookeeper_servers  = undef,
) {
  include monasca
  include monasca::params

  $pers_fetch_url = "http://${blobmirror}/repos/monasca/monasca_persister"
  $latest_pers_deb = "/tmp/${mon_pers_deb}"
  $pers_cfg_file = '/etc/monasca/persister-config.yml'

  wget::fetch { "${pers_fetch_url}/${mon_pers_build_ver}/${mon_pers_deb}":
    destination => $latest_pers_deb,
    timeout     => 300,
    before      => [Package['install-persister'], File[$latest_pers_deb]],
  }

  file { $latest_pers_deb:
    ensure => present,
  }

  package { 'monasca-persister':
    ensure   => latest,
    provider => dpkg,
    source   => $latest_pers_deb,
    alias    => 'install-persister',
  }

  user { $pers_user:
    ensure  => present,
    groups  => $::monasca::group,
    require => Group[$::monasca::group],
  }

  $api_db_password = $::monasca::params::api_db_password

  file { $pers_cfg_file:
    ensure  => file,
    content => template('monasca/persister-config.yml.erb'),
    mode    => '0644',
    owner   => $pers_user,
    group   => $::monasca::group,
    require => [User[$pers_user], Group[$::monasca::group], File[$::monasca::log_dir]],
  }

  service { 'monasca-persister':
    ensure  => running,
    require => [File[$pers_cfg_file],File[$latest_pers_deb],Package['install-persister']],
  }

}
