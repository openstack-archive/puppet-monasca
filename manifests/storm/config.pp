#
# Class for configuring misc storm packages for use by monasca api server
#
class monasca::storm::config (
  $storm_version = 'apache-storm-0.9.2-incubating',
  $mirror = 'http://mirror.cogentco.com/pub/apache/incubator/storm',
  $install_dir = '/opt/storm',
  $storm_user = 'storm',
  $storm_group = 'storm',
  $log_dir = '/var/log/storm',
  $nimbus_server = undef,
) {

  $storm_install_dir = "${install_dir}/current"

  user { $storm_user:
    ensure => present,
  }

  group { $storm_group:
    ensure => present,
  }

  File {
    mode  => '0644',
    owner => $storm_user,
    group => $storm_group,
  }

  file { ['/etc/storm',
  '/usr/lib/storm',
  '/usr/lib/storm/storm-local',
  $install_dir]:
    ensure => directory,
  }

  $tarfile = "${storm_version}.tar.gz"

  wget::fetch { "${mirror}/${storm_version}/${tarfile}":
    destination => "/tmp/${tarfile}",
    timeout     => 120,
    before      => Exec['untar-storm-package']
  }

  exec { "tar -xvzf /tmp/${tarfile}":
    path  => '/bin:/sbin:/usr/bin:/usr/sbin',
    cwd   => $install_dir,
    alias => 'untar-storm-package',
    user  => $storm_user,
    group => $storm_group,
  }

  file { $storm_install_dir:
    ensure => link,
    target => "${install_dir}/${storm_version}"
  }

  file { '/etc/storm/storm.yaml':
    ensure => link,
    target => "${install_dir}/${storm_version}/conf/storm.yaml"
  }

  file { $log_dir:
    ensure => directory,
  }

  monasca::storm::startup_script {
    '/etc/init.d/storm-ui':
      storm_service     => 'ui',
      storm_install_dir => $storm_install_dir,
      storm_user        => $storm_user,
  }
  monasca::storm::startup_script {
    '/etc/init.d/storm-supervisor':
      storm_service     => 'supervisor',
      storm_install_dir => $storm_install_dir,
      storm_user        => $storm_user,
  }

  if ($nimbus_server == 'localhost' or $nimbus_server == $::fqdn) {
    monasca::storm::startup_script {
      '/etc/init.d/storm-nimbus':
        storm_service     => 'nimbus',
        storm_install_dir => $storm_install_dir,
        storm_user        => $storm_user,
    }
  }
}
