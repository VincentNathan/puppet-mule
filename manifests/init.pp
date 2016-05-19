# Class: mule
#
# This module manages the Mule ESB community runtime.
#
# Parameters:
#
# $mule_install_dir::        Where mule will be installed
#
# $mule_version::            The version of mule to install.
#
# $mule_mirror::             The mirror to download from.
#
# $java_home::               Java installation.
#
# $user::                    The system user the mule process will run as.
#
# $group::                   The system group the mule process will run as.
#
# Actions:
#
#   Installs and manages the Mule ESB community runtime.
#
# Requires:
#   Module['Archive']
#   Class['java']
#
# Sample Usage:
#
# node default {
#   class { 'mule': }
# }
#
class mule(
  $mule_mirror = 'https://s3-us-west-2.amazonaws.com/cu-ee',
  $mule_version = '3.7.3',
  $mule_install_dir = '/opt',
  $java_home = '/usr/lib/jvm/jre-1.7.0-oracle.x86_64-1.7.0.85',
  $user = 'root',
  $group = 'root') {

  $basedir = "${mule_install_dir}/mule"
  $dist = "mule-enterprise-standalone-${mule_version}"
  $archive = "${mule_mirror}/${dist}.tar.gz"

  archive { $dist:
    ensure           => present,
    url              => $archive,
    target           => ${mule_install_dir}/${dist},
    checksum         => false,
    timeout          => 0,
    strip_components => 1,
#    root_dir         => '.',
    tar_command      => 'tar',
    follow_redirects => true,
  }

  file { $basedir:
    ensure  => 'link',
    target  => "${mule_install_dir}/${dist}",
    require => Archive[$dist]
  }

  $user_owned_dirs = ["${basedir}/conf", "${basedir}/bin",
                        "${basedir}/domains",
                        "${basedir}/logs",
                        "${basedir}/apps",
                        "${mule_install_dir}/${dist}", ]

  file { $user_owned_dirs:
    ensure  => directory,
    owner   => $user,
    group   => $group,
    require => Archive[$dist],
  }

  file { '/etc/profile.d/mule.sh':
    mode    => '0755',
    content => "export MULE_HOME=${basedir}",
    require => File[$basedir]
  }

  file { '/etc/init.d/mule':
    ensure  => present,
    owner   => 'root',
    group   => '0',
    mode    => '0755',
    content => template('mule/mule.init.erb'),
    require => File[$basedir]
  }

  service { 'mule':
    ensure    => running,
    enable    => true,
    require   => File['/etc/init.d/mule'],
    hasstatus => false
  }

}
