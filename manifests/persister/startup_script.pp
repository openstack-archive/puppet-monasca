#
# Defined type for creating a persister startup script.
#
define monasca::persister::startup_script (
){
  $persister_service_name = $name
  $script = "/etc/init/${persister_service_name}.conf"

  file { $script:
    ensure  => file,
    content => template('monasca/persister-startup-script.erb'),
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
  } ~> Service[$persister_service_name]

}
