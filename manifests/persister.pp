#
# Class to setup monasca persister
#
class monasca::persister (
  $blobmirror         = undef,
  $consumer_id        = 1,
  $batch_size         = 10000,
  $num_threads        = 1,
  $batch_seconds      = 30,
  $config             = $monasca::params::persister_config_defaults,
  $mon_pers_build_ver = undef,
  $mon_pers_deb       = undef,
  $pers_user          = 'persister',
  $zookeeper_servers  = undef,
) {
  include monasca
  include monasca::params

  $pers_fetch_url = "http://${blobmirror}/repos/monasca/monasca_persister"
  $latest_pers_deb = "/tmp/${mon_pers_deb}"

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

  create_resources('monasca::persister::config', $config)
}
