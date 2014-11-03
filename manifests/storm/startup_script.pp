#
# Defined type for creating a storm startup script.
#
define monasca::storm::startup_script (
  $storm_service = undef,
  $storm_install_dir = undef,
  $storm_user = undef) {
    $script = $name
    file { $script:
      ensure  => file,
      content => template('monasca/storm-startup-script.erb'),
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
    }
  }
