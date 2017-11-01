# == Class: monasca::keystone::auth
#
# Configures Monasca user, service and endpoint in Keystone.
#
# === Parameters
# [*auth_name*]
#    Username for Monasca service. Optional. Defaults to 'monasca'.
#
# [*admin_name*]
#    Username for Monasca admin service. Optional. Defaults to 'monasca-admin'.

# [*user_name*]
#    Username for vanilla Monasca user. Optional. Defaults to 'monasca-user'.
#    This user can read and write data for their tenant.
#
# [*agent_name*]
#    Username for Monasca agent service. Optional. Defaults to 'monasca-agent'.
#
# [*admin_password*]
#    Password for Monasca admin user. Required.
#
# [*user_password*]
#    Password for Monasca default user. Required.
#
# [*agent_password*]
#    Password for Monasca agent user. Required.
#
# [*admin_email*]
#   Email for Monasca admin user. Optional. Defaults to 'monasca@localhost'.
#
# [*agent_email*]
#   Email for Monasca agent user. Optional. Defaults to 'monasca@localhost'.
#
# [*user_email*]
#   Email for Monasca default. Optional. Defaults to 'monasca@localhost'.
#
# [*configure_endpoint*]
#   Should Monasca endpoint be configured? Optional. Defaults to 'true'.
#
# [*configure_user*]
#   Should Monasca service user be configured? Optional. Defaults to 'true'.
#
# [*configure_user_role*]
#   Should roles be configured on Monasca service user? Optional. Defaults to 'true'.
#
# [*service_name*]
#   Name of the service. Optional. Defaults to 'monasca'.
#
# [*service_type*]
#    Type of service. Optional. Defaults to 'monitoring'.
#
# [*service_description*]
#    Description for monasca/monitoring service in the keystone service catalog.
#    Optional. Defaults to 'Openstack Monitoring Service'.
#
# [*public_address*]
#    Public address for endpoint. Optional. Defaults to '127.0.0.1'.
#
# [*admin_address*]
#    Admin address for endpoint. Optional. Defaults to '127.0.0.1'.
#
# [*internal_address*]
#    Internal address for endpoint. Optional. Defaults to '127.0.0.1'.
#
# [*port*]
#    Default port for enpoints. Optional. Defaults to '8070'.
#
# [*region*]
#    Region for endpoint. Optional. Defaults to 'RegionOne'.
#
# [*tenant*]
#    Tenant for Monasca user. Optional. Defaults to 'services'.
#
# [*public_protocol*]
#    Protocol for public endpoint. Optional. Defaults to 'http'.
#
# [*admin_protocol*]
#    Protocol for admin endpoint. Optional. Defaults to 'http'.
#
# [*internal_protocol*]
#    Protocol for public endpoint. Optional. Defaults to 'http'.
#
# [*public_url*]
#    The endpoint's public url.
#    Optional. Defaults to $public_protocol://$public_address:$port
#    This url should *not* contain any API version and should have
#    no trailing '/'
#    Setting this variable overrides other $public_* parameters.
#
# [*admin_url*]
#    The endpoint's admin url.
#    Optional. Defaults to $admin_protocol://$admin_address:$port
#    This url should *not* contain any API version and should have
#    no trailing '/'
#    Setting this variable overrides other $admin_* parameters.
#
# [*internal_url*]
#    The endpoint's internal url.
#    Optional. Defaults to $internal_protocol://$internal_address:$port
#    This url should *not* contain any API version and should have
#    no trailing '/'
#    Setting this variable overrides other $internal_* parameters.
#
# [*role_agent*]
#   name for the monasca agent role
#
# [*role_delegate*]
#   name for the monasca delegate role
#
# [*role_admin*]
#   name for the monasca admin role
#
# [*role_user*]
#   name for the monasca user role
#
# [*user_roles_agent*]
#   list of roles to assign to the monasca agent user
#
# [*user_roles_admin*]
#   list of roles to assign to the monasca admin user
#
# [*user_roles_user*]
#   list of roles to assign to the monasca user user
#
class monasca::keystone::auth (
  $auth_name           = 'monasca',
  $admin_email         = 'monasca@localhost',
  $agent_email         = 'monasca@localhost',
  $user_email          = 'monasca@localhost',
  $configure_user      = true,
  $configure_user_role = true,
  $service_name        = 'monasca',
  $service_type        = 'monitoring',
  $service_description = 'Openstack Monitoring Service',
  $public_address      = '127.0.0.1',
  $admin_address       = '127.0.0.1',
  $internal_address    = '127.0.0.1',
  $tenant              = 'services',
  $public_protocol     = 'http',
  $admin_protocol      = 'http',
  $internal_protocol   = 'http',
  $configure_endpoint  = true,
  $public_url          = undef,
  $admin_url           = undef,
  $internal_url        = undef,
  $role_agent          = 'monasca-agent',
  $role_delegate       = 'monitoring-delegate',
  $role_admin          = 'monasca-admin',
  $role_user           = 'monasca-user',
  $user_roles_agent    = undef,
  $user_roles_admin    = undef,
  $user_roles_user     = undef,
) {
  include ::monasca::params

  $admin_name = $::monasca::params::admin_name
  $agent_name = $::monasca::params::agent_name
  $user_name = $::monasca::params::user_name
  $admin_password = $::monasca::params::admin_password
  $agent_password = $::monasca::params::agent_password
  $user_password = $::monasca::params::user_password
  $port = $::monasca::params::port
  $api_version = $::monasca::params::api_version
  $region = $::monasca::params::region

  if $public_url {
    $public_url_real = $public_url
  } else {
    $public_url_real = "${public_protocol}://${public_address}:${port}/${api_version}"
  }

  if $admin_url {
    $admin_url_real = $admin_url
  } else {
    $admin_url_real = "${admin_protocol}://${admin_address}:${port}/${api_version}"
  }

  if $internal_url {
    $internal_url_real = $internal_url
  } else {
    $internal_url_real = "${internal_protocol}://${internal_address}:${port}/${api_version}"
  }

  if $configure_user {
    Keystone_user_role[$agent_name]
      ~> Service <| name == 'monasca-agent' |>
    Keystone_user_role[$user_name]
      ~> Service <| name == 'monasca-agent' |>

    keystone_user { $agent_name:
      ensure   => present,
      password => $agent_password,
      email    => $agent_email,
    }

    keystone_user { $user_name:
      ensure   => present,
      password => $user_password,
      email    => $user_email,
    }
  }

  if $configure_user_role {
    Keystone_user_role["${admin_name}@${tenant}"]
      ~> Service <| name == 'monasca-api' |>
    Keystone_user_role["${agent_name}@${tenant}"]
      ~> Service <| name == 'monasca-api' |>
    Keystone_user_role["${user_name}@${tenant}"]
      ~> Service <| name == 'monasca-api' |>
    Keystone_user_role["${agent_name}@${tenant}"]
      ~> Service <| name == 'monasca-agent' |>
    Keystone_user_role["${user_name}@${tenant}"]
      ~> Service <| name == 'monasca-agent' |>

    if !defined(Keystone_role[$role_agent]) {
      keystone_role { $role_agent:
        ensure => present,
      }
    }
    if !defined(Keystone_role[$role_delegate]) {
      keystone_role { $role_delegate:
        ensure => present,
      }
    }
    if !defined(Keystone_role[$role_admin]) {
      keystone_role { $role_admin:
        ensure => present,
      }
    }
    if !defined(Keystone_role[$role_user]) {
      keystone_role { $role_user:
        ensure => present,
      }
    }

    if $user_roles_agent {
      $real_user_roles_agent = $user_roles_agent
    } else {
      $real_user_roles_agent = [$role_agent, $role_delegate]
    }
    if $user_roles_admin {
      $real_user_roles_admin = $user_roles_admin
    } else {
      $real_user_roles_admin = ['admin']
    }
    if $user_roles_user {
      $real_user_roles_user = $user_roles_user
    } else {
      $real_user_roles_user = [$role_user]
    }

    keystone_user_role { "${agent_name}@${tenant}":
      ensure => present,
      roles  => $real_user_roles_agent,
    }
    keystone_user_role { "${user_name}@${tenant}":
      ensure => present,
      roles  => $real_user_roles_user,
    }
  }

  keystone::resource::service_identity { 'monasca':
    configure_user      => $configure_user,
    configure_user_role => $configure_user_role,
    configure_endpoint  => $configure_endpoint,
    service_type        => $service_type,
    service_description => $service_description,
    service_name        => $service_name,
    region              => $region,
    roles               => $real_user_roles_admin,
    auth_name           => $admin_name,
    password            => $admin_password,
    email               => $admin_email,
    tenant              => $tenant,
    public_url          => $public_url_real,
    admin_url           => $admin_url_real,
    internal_url        => $internal_url_real,
  }

  if $configure_endpoint {
    Keystone_endpoint["${region}/${service_name}::${service_type}"]
      ~> Service <| name == 'monasca-api' |>
  }
}
