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
    sudo packstack --gen-answer-file=ensimag-packstack.txt CONFIG_NTP_SERVERS=10.3.252.26 CONFIG_NEUTRON_ML2_TYPE_DRIVERS=vxlan,flat,vlan CONFIG_NEUTRON_ML2_FLAT_NETWORKS=extnet CONFIG_NEUTRON_ML2_VLAN_RANGES=extnet:2232:2232 CONFIG_NEUTRON_OVS_BRIDGE_IFACES=br-ex:eno1 CONFIG_NEUTRON_OVS_BRIDGEs_COMPUTE=br-ex CONFIG_PROVISION_DEMO=n

    #Deploy PackStack
    sudo packstack --answer-file=ensimag-packstack.txt

    #At this point, try accessing OpenStack via Horizon
    #Ex : 'http://10.11.51.144/dashboard'

    #Source the rc file
    source keystonerc_admin

    #Connect with the external network
#    neutron net-create --router:external --provider:network_type vlan --provider:physical_network extnet --provider:segmentation_id 2232 public
#    neutron subnet-create --name public-subnet --enable_dhcp=False --allocation-pool=start=10.11.54.70,end=10.11.54.89 --gateway=10.11.54.1 public 10.11.54.1/24
}


# Use this to start the vpn in a separate console
# 'sudo openvpn --config vpnlab2017.conf'


echo "Connecting to distant host @10.11.51.144"
ssh -o StrictHostKeyChecking=no root@10.11.51.144 "$(typeset -f); openstack_install; openstack_controller"


echo "Connecting to distant host @10.11.51.145"
ssh -o StrictHostKeyChecking=no root@10.11.51.145 "$(typeset -f); openstack_install; openstack_controller"
