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
  $cache_dir = '/var/cache/storm'
  $config_link = '/etc/storm/storm.yaml'
  $files = [ File[$storm_install_dir], File[$config_link], File[$log_dir] ]

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
    destination => "/${cache_dir}/${tarfile}",
    timeout     => 120,
    before      => Exec['untar-storm-package'],
    cache_dir   => $cache_dir,
    redownload  => false,
    verbose     => true,
  }

  exec { "tar -xvzf /${cache_dir}/${tarfile}":
    path   => '/bin:/sbin:/usr/bin:/usr/sbin',
    cwd    => $install_dir,
    alias  => 'untar-storm-package',
    user   => $storm_user,
    group  => $storm_group,
    before => $files,
  }

  file { $storm_install_dir:
    ensure => link,
    target => "${install_dir}/${storm_version}"
  }

  file { $config_link:
    ensure => link,
    target => "${install_dir}/${storm_version}/conf/storm.yaml"
  }

  file { $log_dir:
    ensure => directory,
  }

  File[$storm_install_dir] ->
  monasca::storm::startup_script {
    '/etc/init.d/storm-ui':
      storm_service     => 'ui',
      storm_install_dir => $storm_install_dir,
      storm_user        => $storm_user,
  }

  File[$storm_install_dir] ->
  monasca::storm::startup_script {
    '/etc/init.d/storm-supervisor':
      storm_service     => 'supervisor',
      storm_install_dir => $storm_install_dir,
      storm_user        => $storm_user,
  }

  #
  # storm-nimbus can take seconds to start, may need a sleep
  # or condition here to wait for it to be up
  #
  if ($nimbus_server == 'localhost' or $nimbus_server == $::fqdn) {
    File[$storm_install_dir] ->
    monasca::storm::startup_script {
      '/etc/init.d/storm-nimbus':
        storm_service     => 'nimbus',
        storm_install_dir => $storm_install_dir,
        storm_user        => $storm_user,
    }
  }
}
