# Class: monasca::dashboard
#
# Sets up monasca dashboard plugin for horizon
#
# Parameters
#
class monasca::dashboard (
  $db_username,
  $db_password,
  $db_url,
  $db_port = '8086',
  $db_name = 'mon',
  $default_board = '/dashboard/file/default.json'
){

  exec { 'monasca_ui':
    command => 'git clone https://github.com/stackforge/monasca-ui.git;
                cp monasca-ui/enabled/* /usr/share/openstack-dashboard/openstack_dashboard/local/enabled;
                cp -r monasca-ui/monitoring /usr/share/openstack-dashboard/;
                cat monasca-ui/config/local_settings.py >> /usr/share/openstack-dashboard/openstack_dashboard/local/local_settings.py;
                rm -rf monasca-ui',
    path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
    creates => '/usr/share/openstack-dashboard/monitoring/dashboard.py',
  }

  exec { 'grafana':
    command => 'git clone https://github.com/hpcloud-mon/grafana.git;
                cp -r grafana/src /usr/share/openstack-dashboard/static/grafana
                rm -rf grafana;',
    path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
    before  => File['grafana_config'],
    creates => '/usr/share/openstack-dashboard/static/grafana/index.html',
  }

  file { 'grafana_config':
    ensure  => file,
    path    => '/usr/share/openstack-dashboard/static/grafana/config.js',
    content => template('monasca/config.js.erb'),
  }

}