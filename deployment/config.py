from pexpect import pxssh
import getpass

def start_packstack(ip):
    try:
        s = pxssh.pxssh()
        s.login(ip, "root", "linux1")
        print("\nEditing network...")
        s.sendline('systemctl disable firewalld')
        s.sendline('systemctl stop firewalld')
        s.sendline('systemctl disable NetworkManager')
        s.sendline('systemctl stop NetworkManager')
        s.sendline('systemctl enable network')
        s.sendline('systemctl start network')

        print("\nInstalling Packstack...")
        s.sendline('yum install -y centos-release-openstack-pike')
        s.sendline('yum update -y')
        s.sendline('sudo yum install -y openstack-packstack')

        print("\nConfiguring Packstack...\n")
        s.sendline('sudo packstack --gen-answer-file=ensimag-packstack.txt CONFIG_NTP_SERVERS=10.3.252.26 CONFIG_NEUTRON_ML2_TYPE_DRIVERS=vxlan,flat,vlan CONFIG_NEUTRON_ML2_FLAT_NETWORKS=extnet CONFIG_NEUTRON_ML2_VLAN_RANGES=extnet:2232:2232 CONFIG_NEUTRON_OVS_BRIDGE_IFACES=br-ex:eno1 CONFIG_NEUTRON_OVS_BRIDGEs_COMPUTE=br-ex CONFIG_PROVISION_DEMO=n CONFIG_CONTROLLER_HOST=10.11.51.145 CONFIG_COMPUTE_HOSTS=10.11.51.144 CONFIG_NETWORK_HOSTS=10.11.51.145')
        s.sendline('sudo packstack --answer-file=ensimag-packstack.txt')
        s.sendline('source keystonerc_admin')
    except pxssh.ExceptionPxssh, e:
        print("pxssh failed on login.")
        print(str(e))


if __name__ == "__main__":
    processes = []
    print("\n#####################")
    print("Setting-Up Packstack")
    print("#####################\n")
    processes.append(start_packstack("10.11.51.144"))
    for p in processes:
        p.wait()
    print("Done")
    #TODO: start network
