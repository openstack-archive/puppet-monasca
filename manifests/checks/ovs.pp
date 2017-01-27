# == Class: monasca::checks::ovs
#
# Sets up the monasca open vswitch check.
#
# === Parameters
#
# [*admin_user*]
#   (Required) Name of the monasca admin.
#
# [*admin_password*]
#   (Required) Password for the monasca admin.
#
# [*admin_tenant_name*]
#   (Required) Name of the monasca admin tenant/project.
#
# [*identity_uri*]
#   (Required) URI of the keystone instance.
#
# [*included_interface_re*]
#   (Optional) Regular expression of interfaces to publish metrics for.
#   Defaults to 'qg.*'.
#
# [*region_name*]
#   (Required) Openstack keystone region for this install.
#
# [*cache_dir*]
#   (Optional) Cache directory to persist data.
#   Defaults to /dev/shm.
#
# [*metadata*]
#   (Optional) A list of router metadata to be submitted as dimensions
#   with service data.  For example, 'tenant_name' in the list will
#   add the tenant name dimension to router metrics posted to the
#   infrastructure project.
#   Defaults to an empty list in the config file.
#
# [*neutron_refresh*]
#   (Optional) Interval to force data refresh from neutron.
#   Defaults to 14400 seconds (4 hours)..
#
# [*check_router_ha*]
#   (Optional) Flag to indicate if additional neutron calls should be
#   made to determine if an HA router is active or standby.
#   Defaults to true.
#
# [*network_use_bits*]
#   (Optional) Flag to indicate bits should be reported instead of bytes.
#   Defaults to true.
#
# [*ovs_cmd*]
#   (Optional) Command to run to get ovs data.
#   Defaults to 'sudo /usr/bin/ovs-vsctl'.
#
# [*publish_router_capacity*]
#   (Optional) Flag indicating if router capacity metrics should be
#   published.
#   Defaults to true.
#
# [*use_absolute_metrics*]
#   (Optional) Flag indicating if absolute metrics should be published
#   for interfaces.
#   Defaults to true.
#
# [*use_health_metrics*]
#   (Optional) Flag indicating if health metrics should be published
#   for interfaces.
#   Defaults to true.
#
# [*use_rate_metrics*]
#   (Optional) Flag indicating if rate metrics should be published
#   for interfaces.
#   Defaults to true.
#
class monasca::checks::ovs(
  $admin_user              = undef,
  $admin_password          = undef,
  $admin_tenant_name       = undef,
  $cache_dir               = '/dev/shm',
  $check_router_ha         = true,
  $identity_uri            = undef,
  $included_interface_re   = 'qg.*',
  $metadata                = [],
  $network_use_bits        = true,
  $neutron_refresh         = '14400',
  $ovs_cmd                 = 'sudo /usr/bin/ovs-vsctl',
  $publish_router_capacity = true,
  $region_name             = undef,
  $use_absolute_metrics    = true,
  $use_health_metrics      = true,
  $use_rate_metrics        = true,
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
