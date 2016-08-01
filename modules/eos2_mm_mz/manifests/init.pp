class eos2_mm_mz {
$master1 = '10.141.56.44'
$master2 = '10.141.60.122'
$master3 = '10.141.56.48'
$cluster = [$master1, $master2, $master3]

#===Install repos===
file { '/etc/yum.repos.d/mesosphere.repo':
    ensure  => present,
    content  => template ('/etc/puppet/modules/eos2_mm_mz/templates/mesosphere.repo.erb'),
}
file { '/etc/yum.repos.d/cloudera-cdh4.repo':
    ensure  => present,
    content => template ('/etc/puppet/modules/eos2_mm_mz/templates/cloudera-cdh4.repo.erb'),
}

#===Mesos master===
package {'mesos':
ensure => installed,
#source => "http://repos.mesosphere.com/el/7/noarch/RPMS/mesosphere-el-repo-7-1.noarch.rpm",
#provider => rpm,
}
service {'mesos-master':
ensure => true,
enable => true,
require => Package['mesos'],
}
#===Marathon===
package {'marathon':
ensure => installed,
#source => "http://repos.mesosphere.com/el/7/noarch/RPMS/mesosphere-el-repo-7-1.noarch.rpm",
#provider => rpm,
}
service {'marathon':
ensure => true,
enable => true,
require => Package['marathon'],
}
#===Zookeeper===
package {'mesosphere-zookeeper':
ensure => installed,
#source => "http://archive.cloudera.com/cdh4/one-click-install/redhat/6/x86_64/cloudera-cdh-4-0.x86_64.rpm",
#provider => rpm,
}
service {'zookeeper':
ensure => running,
enable => true,
require => Package['mesosphere-zookeeper'],
}

file { '/etc/mesos/zk':
    ensure  => present,
    content  => "zk://$master1:2181,$master2:2181,$master3:2181/mesos",
    require => Package['mesos'],
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
file { '/etc/mesos-master/quorum':
    ensure  => present,
    content => "2",
}
case $ipaddress {
    $master1: {
file { '/var/lib/zookeeper/myid':
    ensure  => present, require => Package['mesosphere-zookeeper'], content => '1',}
}
   $master2: {
file { '/var/lib/zookeeper/myid':
    ensure  => present, require => Package['mesosphere-zookeeper'], content => '2',}
}
   $master3: {
file { '/var/lib/zookeeper/myid': 
    ensure  => present, require => Package['mesosphere-zookeeper'], content => '3',}
}
}
file { '/etc/zookeeper/conf/zoo.cfg':
    ensure  => present,
    content => "maxClientCnxns=50
tickTime=2000
initLimit=10
syncLimit=5
dataDir=/var/lib/zookeeper
clientPort=2181
server.1=$master1:2888:3888
server.2=$master2:2888:3888
server.3=$master3:2888:3888
",
    require => Package['mesosphere-zookeeper'],
#    content  => template ('/etc/puppet/modules/eos2_mm_mz/templates/zoo.cfg.erb'),
}
exec { 'zookeeper_restart':command => '/usr/bin/systemctl restart zookeeper.service',}
exec { 'mesos_master_restart':command => '/usr/bin/systemctl restart mesos-master.service',}
exec { 'marathon_restart':command => '/usr/bin/systemctl restart marathon.service',}

#class {'eos2_mm_mz::eos2_ms':
#master1 => $master1,
#master2 => $master2,
#master3 => $master3,
#}
}