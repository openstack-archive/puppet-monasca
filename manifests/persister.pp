# == Class: monasca::persister
#
# Class to setup monasca persister
#
# === Parameters:
#
# [*blobmirror*]
#   location of server to pull debian package from
#
# [*consumer_id*]
#   id of the kafka consumer for this persister
#
# [*batch_size*]
#   batch size of metrics/alarm to persist at the same time
#
# [*num_threads*]
#   number of persister threads
#
# [*batch_seconds*]
#   frequency for this perisiter to write to db
#
# [*config*]
#   persister specific configuration -- allows running multiple persisters.
#
# [*db_admin_password*]
#   admin password for database
#
# [*mon_pers_build_ver*]
#   version of the persister to install
#
# [*mon_pers_deb*]
#   name of the debian package for the persister
#
# [*pers_user*]
#   name of the monasca perisister user
#
# [*zookeeper_servers*]
#   list of zookeeper servers
#
class monasca::persister (
  $blobmirror         = undef,
  $consumer_id        = 1,
  $batch_size         = 10000,
  $num_threads        = 1,
  $batch_seconds      = 30,
  $config             = $monasca::params::persister_config_defaults,
  $db_admin_password  = undef,
  $mon_pers_build_ver = undef,
  $mon_pers_deb       = undef,
  $pers_user          = 'persister',
  $zookeeper_servers  = undef,
) {
  include ::monasca
  include ::monasca::params

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
    tag      => ['openstack', 'monasca-package'],
  }

  user { $pers_user:
    ensure  => present,
    groups  => $::monasca::group,
    require => Group[$::monasca::group],
  }

  create_resources('monasca::persister::config', $config)
}
