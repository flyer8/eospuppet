class eos2_cert {
#===EMC cert installing===
case $operatingsystem {
      centos, redhat: {
$file_ca = '/etc/pki/ca-trust/source/anchors/emc_ca.crt'
$file_ssl = '/etc/pki/ca-trust/source/anchors/emc_ssl.crt'
$cert_extr = '/usr/bin/update-ca-trust extract'
    }
      debian, ubuntu: {
$file_ca = '/usr/local/share/ca-certificates/emc_ca.crt'
$file_ssl = '/usr/local/share/ca-certificates/emc_ssl.crt'
$cert_extr = '/usr/sbin/update-ca-certificates'
    }
}
#===Set Cert files===
file { $file_ca:
ensure => present,
content => template('/etc/puppet/templates/emc_ca.crt.erb'),
mode => 0644,
owner => 'root',
group => 'root'
}
file { $file_ssl:
ensure => present,
content => template('/etc/puppet/templates/emc_ssl.crt.erb'),
mode => 0644,
owner => 'root',
group => 'root'
}
exec { 'update-ca':
    require => File[$file_ca, $file_ssl],
    command => $cert_extr,
}
}
