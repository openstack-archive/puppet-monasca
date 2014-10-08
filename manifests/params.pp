#
class monasca::params {

  if $::osfamily == 'Debian' {
    $agent_package = 'monasca-agent'
    $agent_service = 'monasca-agent'
  } elsif($::osfamily == 'RedHat') {
    $agent_package = false
    $agent_service = ''
  } else {
    fail("unsupported osfamily ${::osfamily}, currently Debian and Redhat are the only supported platforms")
  }
}
