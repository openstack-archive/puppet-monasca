# == Class: monasca
#
# This class sets up configuration common
# across all monasca services.
#
# === Parameters:
# [*log_dir*]
#
# [*monasca_dir*]
#
# [*group*]
#
class monasca(
  $log_dir     = '/var/log/monasca',
  $monasca_dir = '/etc/monasca',
  $group       = 'monasca',
){

  group { $group:
    ensure => present,
  }

  file { $log_dir:
    ensure  => directory,
    owner   => 'root',
    group   => $group,
    mode    => '0775',
    require => Group[$group],
  }

  file { $monasca_dir:
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Group[$group],
  }

}
