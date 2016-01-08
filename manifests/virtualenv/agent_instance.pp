# == Define: virtualenv::agent_instance
#
# Sets up a virtualenv instance and handles agent specific setup in the venv.
# See the instance class for details on using virtualenv instances
#
# === Parameters
#
# [*ensure*] (required) Whether or not the package should be removed or
# installed.  Should be 'present', or 'absent'. For package installs, other
# values such as a version number or 'latest' are also acceptable.
#
# [*venv_active*] (optional) Whether or not the virtualenv should be made
# active by managing symlinks into it and restarting services if the links are
# changed.  Only one virtualenv can be active at a time.  Defaults to false.
#
# [*basedir*] (required) Base directory for storing virtualenvs.
#
# [*symlink*] (required if venv_active is true) The path to link to the venv_dir
#
# [*venv_prefix*] Prefix to give to virtualenv directories
# This can be specified to provide more meaningful names, or to have multiple
# virtualenvs installed at the same time. Defaults to $name
#
# [*venv_requirements*] (required) Python requirements.txt to pass to pip when
# populating the virtualenv.  Required if the instance is ensured to be present.
#
# [*venv_extra_args*] (optional) Extra arguments that will be passed to `pip
# install` when creating the virtualenv.

define monasca::virtualenv::agent_instance(
  $basedir,
  $venv_prefix       = $name,
  $ensure            = 'present',
  $symlink           = undef,
  $venv_requirements = undef,
  $venv_active       = false,
  $venv_extra_args   = undef,
) {
  validate_string($ensure)
  $valid_values = [
    '^present$',
    '^absent$',
  ]
  validate_re($ensure, $valid_values,
    "Unknown value '${ensure}' for ensure, must be present or absent")

  $req_dest = "${basedir}/${venv_prefix}-requirements.txt"
  $venv_path = "${basedir}/${venv_prefix}-venv"

  monasca::virtualenv::instance { $name:
    ensure            => $ensure,
    basedir           => $basedir,
    venv_prefix       => $venv_prefix,
    symlink           => $symlink,
    venv_requirements => $venv_requirements,
    venv_active       => $venv_active,
    venv_extra_args   => $venv_extra_args,
    require           => [File[$basedir],Package['python-virtualenv'],
      Package['python-dev']],
  }
  ->
  file { "${venv_path}/share/monasca/agent/supervisor.conf":
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('monasca/supervisor.conf.erb'),
    notify  => Service['monasca-agent'],
  }
}
