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
    } ->

    #
    # Now start the service -- but don't define as a puppet
    # service, puppet-storm does that.  This just gets it
    # started the first time to keep him happy.
    #
    exec { "${script} start":
      path  => '/bin:/sbin:/usr/bin:/usr/sbin',
      user  => 'root',
      group => 'root',
    }
  }
