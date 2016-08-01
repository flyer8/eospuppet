class eos2_cert_ubuntu {
#===Set Cert files for Ubuntu===
file { '/usr/local/share/ca-certificates/emc_ca.crt':
ensure => present,
content => template('/etc/puppet/templates/emc_ca.crt.erb'),
mode => 0644,
owner => 'root',
group => 'root'
}

file { '/usr/local/share/ca-certificates/emc_ssl.crt':
ensure => present,
content => template('/etc/puppet/templates/emc_ssl.crt.erb'),
mode => 0644,
owner => 'root',
group => 'root'
}
exec { 'update-ca-certificates':
    command => '/usr/sbin/update-ca-certificates',
}
}