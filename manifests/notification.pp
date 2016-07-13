# == Class: monasca::notifications
#
# Class for configuring monasca notifications
#
# === Parameters:
#
# [*notification_user*]
#   name of the monasca notification user
#
# [*from_email_address*]
#   email address to send notifications from
#
# [*install_python_deps*]
#   flag for whether or not to install python dependencies
#
# [*kafka_brokers*]
#   list of kafka broker servers and ports
#
# [*pagerduty_url*]
#   url of pager duty if used as a notification method
#
# [*periodic_kafka_topics*]
#   list of periodic notification kafka topics, defaults
#   to '60: 60-seconds-notifications'
#
# [*periodic_zookeeper_paths*]
#   list of periodic notification zookeeper paths, defaults
#   to '60: /notification/60_seconds'
#
# [*python_dep_ensure*]
#   flag for whether or not to ensure/update python dependencies
#
# [*smtp_password*]
#   password for the smtp server
#
# [*smtp_port*]
#   port on the smtp server to send mail to
#
# [*smtp_server*]
#   host of the smtp server
#
# [*smtp_user*]
#   name to use when authenticating agains the smtp server
#
# [*virtual_env*]
#   directory of python virtual environment
#
# [*webhook_url*]
#   url for webhook notifications
#
# [*zookeeper_servers*]
#   list of zookeeper servers and ports
#
class monasca::notification(
  $notification_user        = 'monasca-notification',
  $from_email_address       = '',
  $install_python_deps      = true,
  $kafka_brokers            = 'localhost:9092',
  $pagerduty_url            = 'https://events.pagerduty.com/generic/2010-04-15/create_event.json',
  $periodic_kafka_topics    = ['60: 60-seconds-notifications'],
  $periodic_zookeeper_paths = ['60: /notification/60_seconds'],
  $python_dep_ensure        = 'present',
  $smtp_password            = '',
  $smtp_port                = 25,
  $smtp_server              = 'localhost',
  $smtp_user                = '',
  $virtual_env              = '/var/www/monasca-notification',
  $webhook_url              = '',
  $zookeeper_servers        = 'localhost:2181',
)
{
  include ::monasca::params

  # variables for the template
  $sql_host     = $::monasca::params::sql_host
  $sql_user     = $::monasca::params::sql_user
  $sql_password = $::monasca::params::sql_password
  $sql_port     = $::monasca::params::sql_port

  $cfg_file = '/etc/monasca/notification.yaml'
  $startup_script = '/etc/init/monasca-notification.conf'

  if $install_python_deps {
    package { ['python-virtualenv', 'python-dev']:
      ensure => $python_dep_ensure,
      before => Python::Virtualenv[$virtual_env],
    }
  }

  python::virtualenv { $virtual_env :
    owner   => 'root',
    group   => 'root',
    require => [Package['python-virtualenv'],Package['python-dev']],
  }

  python::pip { 'monasca-notification' :
    virtualenv => $virtual_env,
    owner      => 'root',
    require    => Python::Virtualenv[$virtual_env],
  }

  user { $notification_user:
    ensure  => present,
    groups  => $::monasca::group,
    require => Group[$::monasca::group],
  }

  file { $cfg_file:
    ensure  => file,
    content => template('monasca/notification.yaml.erb'),
    mode    => '0644',
    owner   => $notification_user,
    group   => $::monasca::group,
    require => [User[$notification_user], Group[$::monasca::group], File[$::monasca::log_dir]],
  } ~> Service['monasca-notification']

  service { 'monasca-notification':
    ensure  => running,
    require => [File[$cfg_file], File[$startup_script]],
    tag     => 'monasca-service',
  }

  file { $startup_script:
    ensure  => file,
    content => template('monasca/notification.conf.erb'),
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
  } ~> Service['monasca-notification']
}
