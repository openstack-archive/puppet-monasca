#
# Class for installing storm
#
class monasca::storm {
  #
  # TODO: modules to be added to puppet file:
  #   maestrodev/wget
  #

  File {
    mode  => '0644',
    owner => 'storm',
    group => 'storm',
  }

  #
  # TODO: pull these from hiera
  #
  $storm_version = 'apache-storm-0.9.2-incubating'
  $mirror = 'http://mirror.cogentco.com/pub/apache/incubator/storm'

  $tarfile = "${storm_version}.tar.gz"
  $install_dir = '/opt/storm'

  file { '/opt/storm':
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
    user  => 'storm',
    group => 'storm',
  }

  file { "${install_dir}/current":
    ensure => link,
    target => "${install_dir}/${storm_version}"
  }

  file { '/var/log/storm':
    ensure => directory,
  }
}
