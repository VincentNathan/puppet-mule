# Class: mule::app::deploy
#
# Deploys a mule application archive to a mule node.
#
# Parameters:
#
# $app_url::                 The url of the mule app archive.
#
# $mule_install_dir::        Optional. Where mule will is installed.
#
# Actions:
#
#   Deploys a mule application archive to a mule node.
#
# Requires:
#   Module['Archive']
#
# Sample Usage:
#
# node default {
#   class { 'mule': }
#   mule::app::deploy { "HelloApp":
#     app_url => 'https://github'
#   }
# }
#
define mule::app::deploy(
  $app_url,
  $mule_install_dir = '/opt/mule') {

  $apps_dir = "${mule_install_dir}/apps"
  $temp_dir = '/tmp'
  $app_name = regsubst($app_url, '(^\w+.*\/)', '')

  archive { $app_name:
    ensure           => present,
    url              => $app_url,
    target           => $temp_dir,
    checksum         => false,
    timeout          => 0,
    strip_components => 1
  }
  file { "${apps_dir}/${app_name}":
    ensure  => 'present',
    source  => "${temp_dir}/${app_name}"
  }

}