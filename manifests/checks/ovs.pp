# == Class: monasca::checks::ovs
#
# Sets up the monasca open vswitch check.
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
# [*cache_dir*]
#   Cache directory to persist data.
#
# [*neutron_refresh*]
#   Interval to force data refresh from neutron.
#
# [*check_router_ha*]
#   Flag to indicate if additional neutron calls should be
#   made to determine if an HA router is active or standby.
#
# [*network_use_bits*]
#   Flag to indicate bits should be reported instead of
#   bytes.
#
# [*ovs_cmd*]
#   Command to run to get ovs data.
#
class monasca::checks::ovs(
  $admin_user        = undef,
  $admin_password    = undef,
  $admin_tenant_name = undef,
  $cache_dir         = '/dev/shm',
  $check_router_ha   = true,
  $identity_uri      = undef,
  $network_use_bits  = true,
  $neutron_refresh   = '14400',
  $ovs_cmd           = 'sudo /usr/bin/ovs-vsctl',
  $region_name       = undef,

){
  $conf_dir = $::monasca::agent::conf_dir

  File["${conf_dir}/ovs.yaml"] ~> Service['monasca-agent']

  file { "${conf_dir}/ovs.yaml":
    owner   => 'root',
    group   => $::monasca::group,
    mode    => '0640',
    content => template('monasca/checks/ovs.yaml.erb'),
    require => File[$conf_dir],
  }
}
