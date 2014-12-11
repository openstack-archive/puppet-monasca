#
# Class for configuring misc storm packages for use by monasca api server
#
class monasca::storm::config (
  $storm_version = 'apache-storm-0.9.3',
  $mirror = 'http://apache.arvixe.com/storm',
  $install_dir = '/opt/storm',
  $storm_user = 'storm',
  $storm_group = 'storm',
  $log_dir = '/var/log/storm',
  $nimbus_server = undef,
) {
  $storm_install_dir = '/etc/storm'
  $cache_dir = '/var/cache/storm'
  $storm_local = '/storm-local'
  $empty_conf_file = "${install_dir}/${storm_version}/conf/storm.yaml"
  $files = [ File[$empty_conf_file], File[$storm_install_dir], File[$log_dir] ]

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

  file { ['/usr/lib/storm', $storm_local, $install_dir]:
    ensure => directory,
  }

  $tarfile = "${storm_version}.tar.gz"

  #
  # The redownload and cache_dir flags will only do the wget if it's changed
  #
  wget::fetch { "${mirror}/${storm_version}/${tarfile}":
    destination => "/${cache_dir}/${tarfile}",
    timeout     => 120,
    before      => Exec['untar-storm-package'],
    cache_dir   => $cache_dir,
    redownload  => false,
    verbose     => true,
  }

  #
  # Only untar if the directory hasn't yet been untarred yet.
  #
  exec { "tar -xvzf /${cache_dir}/${tarfile}":
    path    => '/bin:/sbin:/usr/bin:/usr/sbin',
    cwd     => $install_dir,
    alias   => 'untar-storm-package',
    user    => $storm_user,
    group   => $storm_group,
    before  => $files,
    creates => "${install_dir}/${storm_version}",
  }

  file { $empty_conf_file:
    ensure => absent,
  }

  file { $storm_install_dir:
    ensure => link,
    target => "${install_dir}/${storm_version}",
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

  File[$storm_install_dir] -> File[$storm_local] ->
  monasca::storm::startup_script {
    '/etc/init.d/storm-supervisor':
      storm_service     => 'supervisor',
      storm_install_dir => $storm_install_dir,
      storm_user        => $storm_user,
  }

  if ($nimbus_server == 'localhost' or $nimbus_server == $::fqdn) {
    File[$storm_install_dir] -> File[$storm_local] ->
    monasca::storm::startup_script {
      '/etc/init.d/storm-nimbus':
        storm_service     => 'nimbus',
        storm_install_dir => $storm_install_dir,
        storm_user        => $storm_user,
    }
  }
}
