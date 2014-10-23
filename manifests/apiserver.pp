#
# Class for the monasca api server
#
# TODOS: remove /tmp/*deb
#        pull values from hiera
#
class monasca::apiserver(
  $blobmirror = 'bfd01-blobmirror-001.os.cloud.twc.net',
  $mon_api_build_ver = 'current',
  $mon_pers_build_ver = 'current',
  $mon_thresh_build_ver = 'current',
  $mon_api_deb = 'monasca-api-0.1.0-1414108431485-c6802b.deb',
  $mon_pers_deb = 'monasca-persister-1.0-SNAPSHOT-1414094614742-fbf81b.deb',
  $mon_thresh_deb = 'monasca-thresh-1.0.0-SNAPSHOT-1414094648581-3cfa7c.deb',
){
  ensure_resource('package', 'openjdk-7-jdk', { ensure => 'present' })

  $api_fetch_url = "http://${blobmirror}/repos/monasca/monasca_api"
  $pers_fetch_url = "http://${blobmirror}/repos/monasca/monasca_persister"
  $thresh_fetch_url = "http://${blobmirror}/repos/monasca/monasca_thresh"

  package { 'openjdk-7-jre':
    ensure => present,
    before => Package['install-monasca-api'],
  }

  wget::fetch { "${api_fetch_url}/${mon_api_build_ver}/${mon_api_deb}":
    destination => "/tmp/${mon_api_deb}",
    timeout     => 120,
    before      => Package['install-monasca-api'],
  }

  wget::fetch { "${pers_fetch_url}/${mon_pers_build_ver}/${mon_pers_deb}":
    destination => "/tmp/${mon_pers_deb}",
    timeout     => 120,
    before      => Package['install-monasca-persister'],
  }

  wget::fetch { "${thresh_fetch_url}/${mon_thresh_build_ver}/${mon_thresh_deb}":
    destination => "/tmp/${mon_thresh_deb}",
    timeout     => 120,
    before      => Package['install-monasca-thresh'],
  }

  package { 'monasca-api':
    ensure   => latest,
    provider => dpkg,
    source   => "/tmp/${mon_api_deb}",
    alias    => 'install-monasca-api',
  }

  package { 'monasca-persister':
    ensure   => latest,
    provider => dpkg,
    source   => "/tmp/${mon_pers_deb}",
    alias    => 'install-monasca-persister',
  }

  package { 'monasca-thresh':
    ensure   => latest,
    provider => dpkg,
    source   => "/tmp/${mon_thresh_deb}",
    alias    => 'install-monasca-thresh',
  }
}
