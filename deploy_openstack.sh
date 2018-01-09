#!/bin/bash

#Launch this script to deploy on both instances, or connect via ssh and run commands line by line to locate an error
#To deploy faster, use this script on each instance seperately

network()
{
    #Configure the network
    systemctl disable firewalld
    systemctl stop firewalld
    systemctl disable NetworkManager
    systemctl stop NetworkManager
    systemctl enable network
    systemctl start network
}

openstack_install()
{
    LANG=en_US.utf-8
    LC_ALL=en_US.utf-8

    echo "Packstack deployment"

    #Get the software repositories
    yum install -y centos-release-openstack-pike
    yum update -y
    #Install the PackStack installer
    #yum install -y python-openstackclient
    #yum install -y openstack-selinux
    sudo yum install -y openstack-packstack
}

openstack_controller()
{
    #Create the gen-answer-file
    packstack --gen-answer-file=ensimag-packstack.txt
    sed -i -e 's/CONFIG_NTP_SERVERS=.*/CONFIG_NTP_SERVERS=10.3.252.26/g' ensimag-packstack.txt
    sed -i -e 's/CONFIG_NEUTRON_ML2_TYPE_DRIVERS=.*/CONFIG_NEUTRON_ML2_TYPE_DRIVERS=vxlan,flat,vlan/g' ensimag-packstack.txt
    sed -i -e 's/CONFIG_NEUTRON_ML2_FLAT_NETWORKS=.*/CONFIG_NEUTRON_ML2_FLAT_NETWORKS=extnet/g' ensimag-packstack.txt
    sed -i -e 's/CONFIG_NEUTRON_ML2_VLAN_RANGES=.*/CONFIG_NEUTRON_ML2_VLAN_RANGES=extnet:2232:2232/g' ensimag-packstack.txt
    sed -i -e 's/CONFIG_NEUTRON_OVS_BRIDGE_IFACES=.*/CONFIG_NEUTRON_OVS_BRIDGE_IFACES=br-ex:eno1/g' ensimag-packstack.txt
    sed -i -e 's/CONFIG_NEUTRON_OVS_BRIDGEs_COMPUTE=.*/CONFIG_NEUTRON_OVS_BRIDGEs_COMPUTE=br-ex/g' ensimag-packstack.txt
    sed -i -e 's/CONFIG_PROVISION_DEMO=.*/CONFIG_PROVISION_DEMO=n/g' ensimag-packstack.txt

    #Deploy PackStack
    sudo packstack --answer-file=ensimag-packstack.txt

    #At this point, try accessing OpenStack via Horizon
    #Ex : 'http://10.11.51.144/dashboard'

    #Source the rc file
    source keystonerc_admin

    ##Configure OpenStack
    #openstack user create --domain default --password-prompt neutron
    #openstack role add --project services --user neutron admin
    #openstack service create --name neutron --description "OpenStack Networking" network
    ##Endpoints
    #openstack endpoint create --region RegionOne network public http://controller:9696
    #openstack endpoint create --region RegionOne network internal http://controller:9696
    #openstack endpoint create --region RegionOne network admin http://controller:9696

    #Connect with the external network
    neutron net-create --router:external --provider:network_type vlan --provider:physical_network extnet --provider:segmentation_id 2232 public
    neutron subnet-create --name public-subnet --enable_dhcp=False --allocation-pool=start=10.11.54.70,end=10.11.54.89 --gateway=10.11.54.1 public 10.11.54.1/24
}


# Use this to start the vpn in a separate console
# 'sudo openvpn --config vpnlab2017.conf'


echo "Connecting to distant host @10.11.51.144"
ssh -o StrictHostKeyChecking=no root@10.11.51.144 "$(typeset -f); network; openstack_install; openstack_controller"


echo "Connecting to distant host @10.11.51.145"
ssh -o StrictHostKeyChecking=no root@10.11.51.145 "$(typeset -f); network; openstack_install; openstack_controller"































#OpenStack

database_install() #Used for OpenStack
{
    yum install -y mariadb mariadb-server python2-PyMySQL
    touch /etc/my.cnf.d/openstack.cnf
    echo "[mysqld]" | tee /etc/my.cnf.d/openstack.cnf
    echo "bind-address = 10.11.51.145" | tee -a /etc/my.cnf.d/openstack.cnf
    echo "default-storage-engine = innodb" | tee -a /etc/my.cnf.d/openstack.cnf
    echo "innodb_file_per_table = on" | tee -a /etc/my.cnf.d/openstack.cnf
    echo "max_connections = 4096" | tee -a /etc/my.cnf.d/openstack.cnf
    echo "collation-server = utf8_general_ci" | tee -a /etc/my.cnf.d/openstack.cnf
    echo "character-set-server = utf8" | tee -a /etc/my.cnf.d/openstack.cnf
    systemctl enable mariadb.service
    systemctl start mariadb.service
    mysql_secure_installation
}

message_queue() #Used for OpenStack
{
    mysql_secure_installation
    systemctl enable rabbitmq-server.service
    systemctl start rabbitmq-server.service
    rabbitmqctl add_user openstack mario4
    rabbitmqctl set_permissions openstack ".*" ".*" ".*"
}

memcache() #Used for OpenStack
{
    yum install memcached python-memcached
    sed -i -e 's/OPTIONS="-l 127.0.0.1,::1"/OPTIONS="-l 127.0.0.1,::1,controller"/g' /etc/sysconfig/memcached
    systemctl enable memcached.service
    systemctl start memcached.service
}

services_install() #Used for OpenStack
{
    #Prepare database
    mysql -u root -p
    #After accessing the database, use the following queries :
    #CREATE DATABASE keystone;
    #GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY 'mario4';
    #GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY 'mario4';
    #exit

    #Install and configure components
    yum install -y openstack-keystone httpd mod_wsgi
    sed -i -e "s|#connection\ =\ <None>.*|connection\ =\ mysql+pymysql://keystone:mario4\@controller/keystone|g" /etc/keystone/keystone.conf
    sed -i -e "s/#provider\ =.*/provider\ =\ fernet/g" /etc/keystone/keystone.conf
    su -s /bin/sh -c "keystone-manage db_sync" keystone
    keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
    keystone-manage credential_setup --keystone-user keystone --keystone-group keystone
    keystone-manage bootstrap --bootstrap-password mario4 \
      --bootstrap-admin-url http://controller:35357/v3/ \
      --bootstrap-internal-url http://controller:5000/v3/ \
      --bootstrap-public-url http://controller:5000/v3/ \
      --bootstrap-region-id RegionOne

    #Configure the Apache HTTP server
    sed -i -e 's/ServerName.*/ServerName\ controller/g' /etc/httpd/conf/httpd.conf
    ln -s /usr/share/keystone/wsgi-keystone.conf /etc/httpd/conf.d/

    #Finalize installation
    systemctl enable httpd.service
    systemctl start httpd.service
    #export OS_USERNAME=admin
    #export OS_PASSWORD=mario4
    #export OS_PROJECT_NAME=admin
    #export OS_USER_DOMAIN_NAME=Default
    #export OS_PROJECT_DOMAIN_NAME=Default
    #export OS_AUTH_URL=http://controller:35357/v3
    #export OS_IDENTITY_API_VERSION=3

    #https://docs.openstack.org/install-guide/openstack-services.html
}
