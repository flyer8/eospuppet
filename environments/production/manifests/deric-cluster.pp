#======Mesos master nodes======
node 'srv1', 'srv2', 'srv3' {
$master1 = '10.141.56.170'
$master2 = '10.141.60.124'
$master3 = '10.141.56.175'

class {'mesos':
  repo => 'mesosphere',
  zookeeper => [$master1, $master2, $master3],
}
class{'mesos::master':
  work_dir => '/var/lib/mesos',
  options => {
    quorum   => 2
  }
}
class { 'zookeeper':
servers => [$master1, $master2, $master3]
}
file { '/etc/mesos-master/hostname':
    ensure  => present,
    content  => $ipaddress,
    require => Package['mesos'],
}
file { '/etc/mesos-master/ip':
    ensure  => present,
    content  => $ipaddress,
    require => Package['mesos'],
}
case $ipaddress {
    $master1: {
file { '/var/lib/zookeeper/myid':
#    ensure  => present, 
    require => Package['mesosphere-zookeeper'], content => '1',}
}
   $master2: {
file { '/var/lib/zookeeper/myid':
#    ensure  => present, 
    require => Package['mesosphere-zookeeper'], content => '2',}
}
   $master3: {
file { '/var/lib/zookeeper/myid': 
#    ensure  => present, 
    require => Package['mesosphere-zookeeper'], content => '3',}
}
}
#===Marathon===
package {'marathon':
ensure => installed,
}
service {'marathon':
ensure => true,
enable => true,
require => Package['marathon'],
}

}

#======Mesos slave nodes======
node 'srv-s1', 'srv-s3' {
$master1 = '10.141.56.170'
$master2 = '10.141.60.124'
$master3 = '10.141.56.175'
$ulimit  = 8192

include eos2_cert
include 'docker'

class {'mesos':
  repo => 'mesosphere',
  zookeeper => [$master1, $master2, $master3],
}
class {'mesos::slave':
  resources => {
    'ports' => '[10000-65535]'
  },
  options   => {
    'containerizers' => 'docker,mesos',
#    'hostname'       => $::fqdn,
    'hostname'       => $::ipaddress_eno16777984,
}
}
file {'/etc/mesos-slave/executor_registration_timeout':
    ensure  => present,
    content  => "5mins",
    require => Package['mesos'],
}
file {'/etc/mesos-slave/docker_stop_timeout':
    ensure  => present,
    content  => "10secs",
    require => Package['mesos'],
}
file { '/etc/mesos-slave/ip':
    ensure  => present,
    content  => $ipaddress_eno16777984,
    require => Package['mesos'],
}

exec { 'var_mesos_slave_meta_rm': command => '/usr/bin/rm -f /var/lib/mesos/meta/slaves/latest',}
exec { 'tmp_mesos_slave_meta_rm': command => '/usr/bin/rm -f /tmp/mesos/meta/slaves/latest',}
exec { 'mesos_slave_restart': 
    command => '/usr/bin/systemctl restart mesos-slave.service',
    require => Service['mesos-slave']
}
exec { 'docker-restart':
    path     => ['/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/'],
    command => 'service docker restart',
    require => Service['docker']
  }
docker::image {'jenkins':}

/*
docker::image {'eos2darkside/cloudbees-master-mesos:latest':}
docker::run {'eos2darkside/cloudbees-master-mesos':
  image           => 'eos2darkside/cloudbees-master-mesos',
  ports           => ['7777', '8080'],
  expose          => ['50001', '50000'],
  restart_service => false,
}
*/
}
