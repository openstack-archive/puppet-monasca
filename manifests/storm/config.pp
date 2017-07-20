#
# Class for configuring misc storm packages for use by monasca api server
#
# [*storm_version*]
#   version of apache-storm to use
#
# [*mirror*]
#   location of apache-storm mirror
#
# [*install_dir*]
#   location to install storm
#
# [*storm_user*]
#   name of the storm user
#
# [*storm_group*]
#   name of the storm group
#
# [*log_dir*]
#   directory for storm logs
#
class monasca::storm::config (
  $storm_version = 'apache-storm-0.9.3',
  $mirror = 'http://apache.arvixe.com/storm',
  $install_dir = '/opt/storm',
  $storm_user = 'storm',
  $storm_group = 'storm',
  $log_dir = '/var/log/storm',
) {
  $cache_dir = '/var/cache/storm'
  $storm_local = '/storm-local'

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
    before  => File[$log_dir],
    creates => "${install_dir}/${storm_version}",
  }

  file { "${install_dir}/current":
    ensure => link,
    target => "${install_dir}/${storm_version}",
  }

  file { $log_dir:
    ensure => directory,
  }

  monasca::storm::startup_script {
    '/etc/init.d/storm-ui':
      require           => File[$install_dir],
      storm_service     => 'ui',
      storm_install_dir => "${install_dir}/current",
      storm_user        => $storm_user,
  }

  monasca::storm::startup_script {
    '/etc/init.d/storm-supervisor':
      require           => [ File[$install_dir], File[$storm_local] ],
      storm_service     => 'supervisor',
      storm_install_dir => "${install_dir}/current",
      storm_user        => $storm_user,
  }

  monasca::storm::startup_script {
    '/etc/init.d/storm-nimbus':
      require           => [ File[$install_dir], File[$storm_local] ],
      storm_service     => 'nimbus',
      storm_install_dir => "${install_dir}/current",
      storm_user        => $storm_user,
  }
}
