# == Defined Type: monasca::storm::startup_script
#
# Defined type for creating a storm startup script.
#
# === Parameters:
#
# [*storm_service*]
#   executable for the storm service
#
# [*storm_install_dir*]
#   directory for the storm installation
#
# [*storm_user*]
#   name of the storm user
#
define monasca::storm::startup_script (
  $storm_service = undef,
  $storm_install_dir = undef,
  $storm_user = undef
){
  $script = $name
  file { $script:
    ensure  => file,
    content => template('monasca/storm-startup-script.erb'),
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
  }
}
