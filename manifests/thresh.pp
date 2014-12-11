#
# Class to install monasca api server
#
class monasca::thresh (
  $blobmirror           = undef,
  $mon_thresh_build_ver = undef,
  $mon_thresh_deb       = undef,
) {
  include monasca
  include monasca::params

  $thresh_fetch_url = "http://${blobmirror}/repos/monasca/monasca_thresh"
  $latest_thresh_deb = "/tmp/${mon_thresh_deb}"

  wget::fetch { "${thresh_fetch_url}/${mon_thresh_build_ver}/${mon_thresh_deb}":
    destination => $latest_thresh_deb,
    timeout     => 300,
    before      => [Package['install-thresh'], File[$latest_thresh_deb]],
  }

  file { $latest_thresh_deb:
    ensure => present,
  }

  package { 'monasca-thresh':
    ensure   => latest,
    provider => dpkg,
    source   => $latest_thresh_deb,
    alias    => 'install-thresh',
  }

}
