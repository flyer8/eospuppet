class eos2_ms {
$master1 = '10.141.56.44'
$master2 = '10.141.60.122'
$master3 = '10.141.56.48'

#===Install repos===
file { '/etc/yum.repos.d/mesosphere.repo':
    ensure  => present,
    content  => template ('/etc/puppet/modules/eos2_mm_mz/templates/mesosphere.repo.erb'),
}
file { '/etc/yum.repos.d/cloudera-cdh4.repo':
    ensure  => present,
    content => template ('/etc/puppet/modules/eos2_mm_mz/templates/cloudera-cdh4.repo.erb'),
}

#===Mesos slave===
package {'mesos':
ensure => installed,
}
service {'mesos-master':
ensure => false,
enable => false,
require => Package['mesos'],
}
service {'mesos-slave':
ensure => true,
enable => true,
require => Package['mesos'],
}

file { '/etc/mesos/zk':
    ensure  => present,
    content => "zk://$master1:2181,$master2:2181,$master3:2181/mesos",
#    content  => template ('/etc/puppet/modules/eos2_mm_mz/templates/zk.erb'),
    require => Package['mesos'],
}
file { '/etc/mesos-slave/hostname':
    ensure  => present,
    content  => $ipaddress_eno16777984,
    require => Package['mesos'],
}
file { '/etc/mesos-slave/ip':
    ensure  => present,
    content  => $ipaddress_eno16777984,
    require => Package['mesos'],
}

exec { 'mesos_slave_restart':command => '/usr/bin/systemctl restart mesos-slave.service',}
}