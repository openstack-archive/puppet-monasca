# == Class: monasca::checks::libvirt
#
# Sets up the monasca libvirt check.
# Requires lxml, libvirt-python and python-novaclient
#
# === Parameters
#
# [*admin_password*]
#   (Required) Password for the monasca admin.
#
# [*admin_tenant_name*]
#   (Required) Name of the monasca admin tenant/project.
#
# [*admin_user*]
#   (Required) Name of the monasca admin.
#
# [*alive_only*]
#   (Optional) Will suppress all per-VM metrics aside from host_alive_status
#   and vm.host_alive_status, including all I/O, network, memory, ping, and
#   CPU metrics.  Aggregate metrics, however, would still be enabled if alive_only
#   is true.
#   Defaults to false.
#
# [*cache_dir*]
#   (Optional) Cache directory to persist data.
#   Defaults to '/dev/shm'.
#
# [*customer_metadata*]
#   (Optional) A list of instance metadata to be submitted as dimensions
#   with customer data.
#   Defaults to not set in the config file.
#
# [*disk_collection_period*]
#   (Optional) Have disk metrics be outputted  less often to reduce
#   metric load on the system. If this is less than the agent collection
#   period, it will be ignored.
#   Defaults to 0.
#
# [*host_aggregate_re*]
#   (Optional) Regular expression of host aggregate names to match, which
#   will add a 'host_aggregate' dimension to libvirt metrics for the operations
#   project.
#   Defaults to undef -- causing the flag to not be set in the config file.
#
# [*identity_uri*]
#   (Required) URI of the keystone instance.
#
# [*metadata*]
#   (Optional) A list of instance metadata to be submitted as dimensions
#   with service data.
#   Defaults to not set in the config file.
#
# [*network_use_bits*]
#   (Optional) Submit network metrics in bits rather than bytes.
#   Defaults to true.
#
# [*nova_refresh*]
#   (Optional) Interval to force data refresh.  Set to 0 to refresh every time
#   the collector runs, or to None to disable regular refreshes entirely (though
#   the instance cache will still be refreshed if a new instance is detected).
#   Defaults to 14400 (4 hours).
#
# [*ping_check*]
#   (Optional) The entire command line (sans the IP address, which is automatically
#   appended) used to perform a ping check against instances, with a keyword NAMESPACE
#   automatically replaced with the appropriate network namespace for the VM being
#   monitored.  Set to false to disable ping checks.
#   Defaults to false.
#
# [*region_name*]
#   (Required) Openstack keystone region for this install.
#
# [*vm_cpu_check_enable*]
#   (Optional) Enables collecting of VM CPU metrics.
#   Defaults to true.
#
# [*vm_disks_check_enable*]
#   (Optional) Enables collecting of VM disk metrics.
#   Defaults to true.
#
# [*vm_extended_disks_check_enable*]
#   (Optional) nable collecting of extended disk metrics.
#   Defaults to false.
#
# [*vm_network_check_enable*]
#   (Optional) Enables collecting of VM network metrics.
#   Defaults to true.
#
# [*vm_ping_check_enable*]
#   (Optional) Enables host alive ping check.
#   Defaults to false.
#
# [*vm_probation*]
#   (Optional) Period of time (in seconds) in which to suspend metrics
#   from a newly-created VM.  This is to prevent quickly-obsolete metrics
#   in an environment with a high amount of instance churn.
#   Defaults to 300 seconds.
#
class monasca::checks::libvirt(
  $admin_password                 = undef,
  $admin_tenant_name              = undef,
  $admin_user                     = undef,
  $alive_only                     = false,
  $cache_dir                      = '/dev/shm',
  $customer_metadata              = [],
  $disk_collection_period         = 0,
  $host_aggregate_re              = undef,
  $identity_uri                   = undef,
  $metadata                       = [],
  $network_use_bits               = true,
  $nova_refresh                   = '14400',
  $ping_check                     = false,
  $region_name                    = undef,
  $vm_cpu_check_enable            = true,
  $vm_disks_check_enable          = true,
  $vm_extended_disks_check_enable = false,
  $vm_network_check_enable        = true,
  $vm_ping_check_enable           = false,
  $vm_probation                   = '300',
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
