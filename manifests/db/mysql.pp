#
# Class to configure monasca's mysql database, which is used
# for configuration of thresholds, alarms, etc.
#
class monasca::db::mysql {
  include ::monasca::params

  $sql_host            = $::monasca::params::sql_host
  $sql_user            = $::monasca::params::sql_user
  $sql_password        = $::monasca::params::sql_password
  $sql_port            = $::monasca::params::sql_port
  $monsql              = '/tmp/mon.sql'
  $mysql_user_class    = 'mysql_user'
  $monasca_remote      = 'monasca@%'
  $notification_local  = 'notification@localhost'
  $notification_remote = 'notification@%'
  $thresh_local        = 'thresh@localhost'
  $thresh_remote       = 'thresh@%'

  $prereqs = [
    Mysql_user[$monasca_remote],
    Mysql_user[$notification_local],
    Mysql_user[$notification_remote],
    Mysql_user[$thresh_local],
    Mysql_user[$thresh_remote],
    File[$monsql]]

  file { $monsql:
    ensure  => file,
    content => template('monasca/mon.sql.erb'),
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
  }

  mysql::db { 'mon':
    user     => 'monasca',
    password => $sql_password,
    host     => 'localhost',
    sql      => $monsql,
    require  => $prereqs,
  }

  $user_resource = {
    ensure        => present,
    password_hash => mysql_password($sql_password),
    provider      => 'mysql',
    require       => Class['mysql::server'],
  }

  #
  # We get the monasca local user for free above in the db declaration.
  #
  ensure_resource($mysql_user_class, $monasca_remote, $user_resource)
  ensure_resource($mysql_user_class, $notification_local, $user_resource)
  ensure_resource($mysql_user_class, $notification_remote, $user_resource)
  ensure_resource($mysql_user_class, $thresh_local, $user_resource)
  ensure_resource($mysql_user_class, $thresh_remote, $user_resource)
}
