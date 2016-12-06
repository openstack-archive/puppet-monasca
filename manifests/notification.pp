# == Class: monasca::notification
#
# Class for configuring monasca notifications
#
# === Parameters:
#
# [*from_email_address*]
#   (Optional) Email address to send notifications from.
#   Defaults to empty string.
#
# [*hipchat_ca_certs*]
#   (Optional) CA cert file for hipchat notifications
#   Defaults to "/etc/ssl/certs/ca-certificates.crt"
#
# [*hipchat_insecure*]
#   (Optional) Flag to indicate if hipchat notification calls should
#   be insecure.
#   Defaults to False
#
# [*install_python_deps*]
#   (Optional) Flag for whether or not to install python dependencies.
#   Defaults to true.
#
# [*kafka_brokers*]
#   (Optional) List of kafka broker servers and ports.
#   Defaults to 'localhost:9092'.
#
# [*notification_user*]
#   (Optional) Name of the monasca notification user.
#   Defaults to 'monasca-notification'.
#
# [*pagerduty_url*]
#   (Optional) URL of pager duty if used as a notification method.
#   Defaults to 'https://events.pagerduty.com/generic/2010-04-15/create_event.json'.
#
# [*periodic_kafka_topics*]
#   (Optional) List of periodic notification kafka topics
#   Defaults to '60: 60-seconds-notifications'
#
# [*periodic_zookeeper_paths*]
#   (Optional) List of periodic notification zookeeper paths
#   Defaults to '60: /notification/60_seconds'
#
# [*python_dep_ensure*]
#   (Optional) Flag for whether or not to ensure/update python dependencies.
#   Defaults to 'present'.
#
# [*slack_ca_certs*]
#   (Optional) CA cert file for slack notifications.
#   Defaults to "/etc/ssl/certs/ca-certificates.crt".
#
# [*slack_insecure*]
#   (Optional) Flag to indicate if slack notification calls should
#   be insecure.
#   Defaults to False.
#
# [*smtp_password*]
#   (Optional) Password for the smtp server.
#   Defaults to empty string.
#
# [*smtp_port*]
#   (Optional) Port on the smtp server to send mail to.
#   Defaults to 25.
#
# [*smtp_server*]
#   (Optional) Host of the smtp server.
#   Defaults to 'localhost'.
#
# [*smtp_user*]
#   (Optional) Name to use when authenticating agains the smtp server.
#   Defaults to empty string.
#
# [*virtual_env*]
#   directory of python virtual environment
#
# [*webhook_url*]
#   (Optional) URL for webhook notifications.
#   Defaults to empty string.
#
# [*zookeeper_servers*]
#   (Optional) List of zookeeper servers and ports.
#   Defaults to 'localhost:2181'.
#
class monasca::notification(
  $from_email_address       = '',
  $hipchat_ca_certs         = '/etc/ssl/certs/ca-certificates.crt',
  $hipchat_insecure         = false,
  $install_python_deps      = true,
  $kafka_brokers            = 'localhost:9092',
  $notification_user        = 'monasca-notification',
  $pagerduty_url            = 'https://events.pagerduty.com/generic/2010-04-15/create_event.json',
  $periodic_kafka_topics    = ['60: 60-seconds-notifications'],
  $periodic_zookeeper_paths = ['60: /notification/60_seconds'],
  $python_dep_ensure        = 'present',
  $slack_ca_certs           = '/etc/ssl/certs/ca-certificates.crt',
  $slack_insecure           = false,
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
    # Name virtualenv instead of python-virtualenv for compat with puppet-python
    package { 'virtualenv':
      ensure => $python_dep_ensure,
      name   => 'python-virtualenv',
      before => Python::Virtualenv[$virtual_env],
    }

    package { 'python-dev':
      ensure => $python_dep_ensure,
      before => Python::Virtualenv[$virtual_env],
    }
  }

  python::virtualenv { $virtual_env :
    owner   => 'root',
    group   => 'root',
    require => [Package['virtualenv'],Package['python-dev']],
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
