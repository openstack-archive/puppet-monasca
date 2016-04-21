# == Class: monasca::checks::libvirt
#
# Sets up the monasca libvirt check.
# Requires lxml, libvirt-python and python-novaclient
#
# === Parameters
#
# [*admin_user*]
#   name of the monasca admin
#
# [*admin_password*]
#   password for the monasca admin
#
# [*admin_tenant_name*]
#   name of the monasca admin tenant/project
#
# [*identity_uri*]
#   uri of the keystone instance
#
# [*region_name*]
#   openstack keystone region for this install
#
# [*heat_scale_group*]
#   flag to indicate if scale group should be posted
#
# [*cache_dir*]
#   Cache directory to persist data.
# [*vm_probation*]
#   Period of time (in seconds) in which to suspend metrics from a newly-created VM.
#   This is to prevent quickly-obsolete metrics in an environment with a high amount
#   of instance churn.
# [*nova_refresh*]
#   Interval to force data refresh.  Set to 0 to refresh every time the
#   Collector runs, or to None to disable regular refreshes entirely (though
#   the instance cache will still be refreshed if a new instance is detected).
#
class monasca::checks::libvirt(
  $admin_user,
  $admin_password,
  $admin_tenant_name,
  $heat_scale_group  = false,
  $identity_uri,
  $region_name       = undef,
  $cache_dir         = '/dev/shm',
  $vm_probation      = '300',
  $nova_refresh      = '14400'
){
  $conf_dir = $::monasca::agent::conf_dir

  File["${conf_dir}/libvirt.yaml"] ~> Service['monasca-agent']

  file { "${conf_dir}/libvirt.yaml":
    owner   => 'root',
    group   => $::monasca::group,
    mode    => '0640',
    content => template('monasca/checks/libvirt.yaml.erb'),
    require => File[$conf_dir],
  }

  # libxslt1-dev, libxml2-dev and zlib1g-dev are needed for lxml install
  ensure_packages('libxslt1-dev')
  ensure_packages('libxml2-dev')
  ensure_packages('zlib1g-dev')
  # libvirt-dev and pkg-config are needed libvirt-python
  ensure_packages('libvirt-dev')
  ensure_packages('pkg-config')
}
