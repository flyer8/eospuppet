node 'srv-test7.cec.lab.emc.com' {
include eos2_cert
#===Install, Pull and run Cloudbees on Ubuntu===
include 'docker'
docker::image {'eos2darkside/cloudbees-master-mesos':}
exec { 'docker_run_cloudbess':
    command => '/usr/bin/docker run -d -p 7777:8080 -p 50001:50000 eos2darkside/cloudbees-master-mesos',
}
}
