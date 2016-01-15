# == Define: virtualenv::instance
#
# This class will manage the installation of the monasca agent into a Python
# virtualenv.  It will also manage the config files needed by that software,
# with different policies for packages and virtualenvs.  By default the config
# files will be copied from the template files internal to the module.  This
# behavior can be overridden by providing a $config_files hash.
#
# Virtualenv installations are built by installing packages from a given
# requirements.txt file. For production use you will normally want to override
# the requirements.txt and provide one that contains pinned module versions,
# and possibly include information about a local pypi mirror in the
# requirements.txt.
#
# This module explicitly supports provisioning multiple virtualenv based
# installations in order to make upgrades and rollbacks easier.  To take
# advantage of this, you can define additional instances of
# monasca::virtualenv::instance type with the active flag set to false
# and with different $venv_prefix options.  The monasca::agent class will allow
# configuring multiple virtualenvs via hiera.
#
# If using virtualenv based installations it's *strongly* recommended that
# virtualenvs be treated as immutable once created.  Behavior with changing
# requirements.txt or code may not be what you expect, since the existing
# virtualenv will be updated, not rebuilt when requirements.txt or the git
# revision changes.
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

define monasca::virtualenv::instance(
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
  $venv_dir = "${basedir}/${venv_prefix}-venv"
  $venv_name = "${venv_prefix}-${name}"

  if $ensure == 'present' {
    validate_string($venv_requirements)

    file { $req_dest:
      ensure => 'file',
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      source => $venv_requirements,
      before => Python::Virtualenv[$venv_name],
    }
  } else {
    file { $req_dest:
      ensure => 'absent',
    }
  }

  python::virtualenv { $venv_name:
    ensure         => $ensure,
    venv_dir       => $venv_dir,
    requirements   => $req_dest,
    extra_pip_args => $venv_extra_args,
    owner          => 'root',
    group          => 'root',
  }

  if $venv_active {
    file { $symlink:
      ensure => 'link',
      force  => true,
      target => $venv_dir,
    }
  }
}
