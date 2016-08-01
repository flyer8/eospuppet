class tomcat_cloudbees {
#=== Install Tomcat 8 with Java 8===
    include java8
    tomcat::install { '/opt/tomcat8':
    source_url => 'https://www.apache.org/dist/tomcat/tomcat-8/v8.0.35/bin/apache-tomcat-8.0.35.tar.gz',
}
    tomcat::instance { 'default':
    catalina_home => '/opt/tomcat8',
}
# Deploy war file
    tomcat::war { 'jenkins-oc.war':
    catalina_base => '/opt/tomcat8',
    war_source    => 'http://nectar-downloads.cloudbees.com/jenkins-operations-center/latest/latest/jenkins-oc.war',
}
exec { 'tomcat_shutdown':
    command => '/opt/tomcat8/bin/shutdown.sh',}
exec { 'tomcat_startup':
    command => '/opt/tomcat8/bin/startup.sh',}
}