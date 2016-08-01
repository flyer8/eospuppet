node 'alpha', 'bravo', 'charlie' {
#===Mesos Masters===
include eos2_mm_mz
class { '::consul':
  config_hash => {
    'bootstrap_expect' => 1,
    'data_dir'         => '/opt/consul',
    'datacenter'       => 'eos2',
    'log_level'        => 'INFO',
#    'node_name'        => 'server',
    'server'           => true,
    'client_addr'      => '0.0.0.0',
    'ui_dir'           => '/opt/consul/ui',
    'retry_join' => ['10.141.56.44'],
#    'retry_join' => ['10.141.56.44', '10.141.60.122', '10.141.56.48'],
}
}

file { '/etc/consul/bootstrap.json':
ensure => present,
content => template('/etc/puppet/environments/production/modules/consul/templates/bootstrap.json.erb'),
require => Package['mesos'],
}
#exec { 'bootstrap_start':command => '/usr/local/bin/consul agent -config-dir=/etc/consul/bootstrap.json',}

::consul::service { 'marathon':
  checks  => [
    {
      http   => "http://$ipaddress_eno16777984",
      interval => '10s'
    }
  ],
  port    => 8080,
  tags    => ['master']
}

::consul::service { 'mesos-master':
  checks  => [
    {
      http   => "http://$ipaddress_eno16777984",
      interval => '10s'
    }
  ],
  port    => 5050,
  tags    => ['master']
}

::consul::service { 'zookeeper':
  checks  => [
    {
      tcp   => $ipaddress_eno16777984,
      interval => '10s'
    }
  ],
  port    => 2181,
  tags    => ['master']
}


}

node 'mslave1', 'mslave2', 'mslave3' {
include eos2_cert
#===Mesos slaves===
class {'eos2_mm_mz::eos2_ms':}
include 'docker'
exec { 'docker-restart':
    path     => ['/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/'],
    command => 'service docker restart',
    require => Service['docker']
  }
docker::image {'jenkins':}
exec { 'mesos_slave_restart':command => '/usr/bin/systemctl restart mesos-slave.service',}

class { '::consul':
  config_hash => {
    'data_dir'   => '/opt/consul',
    'datacenter' => 'eos2',
    'log_level'  => 'INFO',
#    'node_name'  => 'agent',
#    'retry_join' => ['10.141.56.44', '10.141.60.122', '10.141.56.48'],
    'retry_join' => ['10.141.56.44'],
  }
}

}
