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
  $mule_mirror = 'https://repository.mulesoft.org/nexus/content/repositories/releases/org/mule/distributions/mule-standalone/',
  $mule_version = '3.7.0',
  $mule_install_dir = '/opt',
  $java_home = '/usr/lib/jvm/default-java',
  $user = 'root',
  $group = 'root') {

  $basedir = "${mule_install_dir}/mule"
  $dist = "mule-standalone-${mule_version}"
  $archive = "${dist}.tar.gz"

  archive { $dist:
    ensure           => present,
    url              => "${mule_mirror}/${archive}",
    target           => $mule_install_dir,
    checksum         => false,
    timeout          => 0
  }

  file { $basedir:
    ensure  => 'link',
    target  => "${mule_install_dir}/${dist}",
    require => Archive[$dist]
  }

  file { "${mule_install_dir}/${dist}":
    ensure  => directory,
    owner   => $user,
    group   => $group,
    require => Archive[$dist]
  }

  file { '/etc/profile.d/mule.sh':
    mode    => '0755',
    content => "export MULE_HOME=${basedir}",
    require => File[$basedir]
  }

  file { '/etc/init.d/mule':
    ensure  => present,
    owner   => $user,
    group   => $group,
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