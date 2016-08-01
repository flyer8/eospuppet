# == Class: docker::system_restart
#
class docker::system_restart {
#exec { 'update_ca_restart': command => '/usr/bin/update-ca-trust extract',}
  exec { 'docker-restart':
    path        => ['/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/'],
    command     => 'service docker restart',
    refreshonly => true,
  }
}
