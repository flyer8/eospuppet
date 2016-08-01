node default {
    include eos2_cert
}

node 'srv-test4.cec.lab.emc.com' { include eos2_cert }

node 'srv-test6.cec.lab.emc.com' { include tomcat_cloudbees }

node 'srv-test7.cec.lab.emc.com' {
#===Install, Pull and run Cloudbees on Ubuntu===
include 'docker'
docker::image {'eos2darkside/cloudbees-master-mesos':}
exec { 'docker_run_cloudbess':
    command => '/usr/bin/docker run -d -p 7777:8080 -p 50001:50000 eos2darkside/cloudbees-master-mesos',
}
}

node 'srv1', 'srv2', 'srv3' {
# Unique myid generating in each master node issue in /var/lib/zookeeper/myid
class {'mesos':
  repo => 'mesosphere',
  zookeeper => [ '10.141.56.170', '10.141.60.124', '10.141.56.175'],
}
class{'mesos::master':
  work_dir => '/var/lib/mesos',
  options => {
    quorum   => 2
  }
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
class { 'zookeeper':
  servers => ['10.141.56.170', '10.141.60.124', '10.141.56.175']
}
}

node 'slave' {
class{'mesos':
  repo => 'mesosphere',
  zookeeper => [ '10.141.56.170', '10.141.60.124', '10.141.56.175'],
}
class{'mesos::slave':
  resources => {
    'ports' => '[10000-65535]'
  },
  options   => {
    'containerizers' => 'docker,mesos',
#    'hostname'       => $::fqdn,
    'hostname'       => $::ipaddress,
  }
}
file { '/etc/mesos-slave/ip':
    ensure  => present,
    content  => $ipaddress,
    require => Package['mesos'],
}
}

node 'alpha', 'bravo', 'charlie' {
include eos2_mm_mz
}

node 'mslave1', 'mslave2', 'mslave3' {
class {'eos2_mm_mz::eos2_ms':}
include 'docker'
exec { 'docker_restart': command => '/usr/bin/update-ca-trust extract && /usr/sbin/service docker restart',}
docker::image {'eos2darkside/cloudbees-master-mesos:latest':}
docker::run {'eos2darkside/cloudbees-master-mesos':
  image           => 'eos2darkside/cloudbees-master-mesos',
  ports           => ['7777', '8080'],
#  expose          => ['50001', '50000'],
  restart_service => false,
}
exec { 'mesos_slave_restart':command => '/usr/bin/systemctl restart mesos-slave.service',}
}
