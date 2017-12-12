#!/bin/bash

network()
{
    sudo systemctl disable firewalld
    sudo systemctl stop firewalld
    sudo systemctl disable NetworkManager
    sudo systemctl stop NetworkManager
    sudo systemctl enable network
    sudo systemctl start network
}

packstack()
{
    LANG=en_US.utf-8
    LC_ALL=en_US.utf-8
    
    echo "Packstack deployment"

    #Get the software repositories
    sudo yum install -y https://www.rdoproject.org/repos/rdo-release.rpm
    sudo yum-config-manager --enable openstack-pike
    sudo yum update -y
    #Install the Packstack installer
    sudo yum install -y openstack-packstack
}

deploy()
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

    #Connect with the external network
    openstack network create --external --provider-network-type vlan --provider-physical-network extnet --provider-segment 2232 public
    neutron subnet-create --name public-subnet --enable_dhcp=False --allocation-pool=start=10.11.54.70,end=10.11.54.89 --gateway=10.11.54.1 public 10.11.54.1/24
}

# Use this to start the vpn in a separate console
# sudo openvpn --config vpnlab2017.conf


echo "Connecting to distant host @10.11.51.144"
ssh -o root@10.11.51.144 "$(typeset -f); network; packstack"


echo "Connecting to distant host @10.11.51.145"
ssh -o root@10.11.51.145 "$(typeset -f); network; packstack"
