class eos2_cert_centos {
#===Set Cert files for Centos===
file { '/etc/pki/ca-trust/source/anchors/emc_ca.crt':
ensure => present,
content => template('/etc/puppet/templates/emc_ca.crt.erb'),
mode => 0644,
owner => 'root',
group => 'root'
}

file { '/etc/pki/ca-trust/source/anchors/emc_ssl.crt':
ensure => present,
content => template('/etc/puppet/templates/emc_ssl.crt.erb'),
mode => 0644,
owner => 'root',
group => 'root'
}
exec { 'update-ca-trust':
    command => '/usr/bin/update-ca-trust extract',
}
}