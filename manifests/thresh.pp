#
# Class to install monasca thresholding engine
#
# [*blobmirror*]
#   location of the server to pull debians from
#
# [*kafka_brokers*]
#   list of kafka brokers
#
# [*mon_thresh_build_ver*]
#   version of the thresh debian package
#
# [*mon_thresh_deb*]
#   name of the thresh debian package
#
# [*zookeeper_servers*]
#   list of zookeeper servers
#
class monasca::thresh (
  $blobmirror           = undef,
  $kafka_brokers        = undef,
  $mon_thresh_build_ver = undef,
  $mon_thresh_deb       = undef,
  $zookeeper_servers    = undef,
) {
  include ::monasca
  include ::monasca::params

  # variables for the template
  $sql_host     = $::monasca::params::sql_host
  $sql_user     = $::monasca::params::sql_user
  $sql_password = $::monasca::params::sql_password
  $sql_port     = $::monasca::params::sql_port

  $thresh_fetch_url = "http://${blobmirror}/repos/monasca/monasca_thresh"
  $latest_thresh_deb = "/tmp/${mon_thresh_deb}"
  $thresh_cfg_file = '/etc/monasca/thresh-config.yml'
  $startup_script = '/etc/init.d/monasca-thresh'
  $startup_script_src = 'puppet:///modules/monasca/monasca-thresh'

  wget::fetch { "${thresh_fetch_url}/${mon_thresh_build_ver}/${mon_thresh_deb}":
    destination => $latest_thresh_deb,
    timeout     => 300,
    before      => [Package['install-thresh'], File[$latest_thresh_deb]],
  } ~> Service['monasca-thresh']

  file { $latest_thresh_deb:
    ensure => present,
  }

  file { $thresh_cfg_file:
    ensure  => file,
    content => template('monasca/thresh-config.yml.erb'),
    mode    => '0644',
    owner   => 'root',
    group   => $::monasca::group,
    require => [Group[$::monasca::group], File[$::monasca::log_dir]],
  }

  package { 'monasca-thresh':
    ensure   => latest,
    provider => dpkg,
    source   => $latest_thresh_deb,
    alias    => 'install-thresh',
    tag      => ['openstack', 'monasca-package'],
  }

  service { 'monasca-thresh':
    ensure  => running,
    require => [File[$thresh_cfg_file],
                File[$latest_thresh_deb],
                File[$startup_script],
                User['thresh']],
    tag     => 'monasca-service',
  }

  user { 'thresh':
    ensure  => present,
    groups  => $::monasca::group,
    require => Group[$::monasca::group],
  }

  file { $startup_script:
    ensure  => file,
    source  => $startup_script_src,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    require => Package['install-thresh'],
  }
}
