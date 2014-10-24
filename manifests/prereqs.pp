#
# Class for installing monasca api prerequisites that don't currently
# have easy modules
#
class monasca::prereqs (
  $storm_version = 'apache-storm-0.9.2-incubating',
  $mirror = 'http://mirror.cogentco.com/pub/apache/incubator/storm',
  $install_dir = '/opt/storm',
  $storm_user = 'storm',
  $storm_group = 'storm',
  $log_dir = '/var/log/storm',
) {

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

  $tarfile = "${storm_version}.tar.gz"

  file { $install_dir:
    ensure => directory,
  }

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

  file { "${install_dir}/current":
    ensure => link,
    target => "${install_dir}/${storm_version}"
  }

  file { $log_dir:
    ensure => directory,
  }
}
