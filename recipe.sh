#!/bin/bash
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
#  Example Installation Script Template
#  
#  This convenience script encapsulates command-line instructions highlighted in
#  the OpenHPC Install Guide that can be used as a starting point to perform a local
#  cluster install beginning with bare-metal. Necessary inputs that describe local
#  hardware characteristics, desired network settings, and other customizations
#  are controlled via a companion input file that is used to initialize variables 
#  within this script.
#   
#  Please see the OpenHPC Install Guide for more information regarding the
#  procedure. Note that the section numbering included in this script refers to
#  corresponding sections from the install guide.
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

inputFile=input.local

if [ ! -e ${inputFile} ];then
   echo "Error: Unable to access local input file -> ${inputFile}"
   exit 1
else
   . ${inputFile} || { echo "Error sourcing ${inputFile}"; exit 1; }
fi

echo "---------------------------- Begin OpenHPC Recipe ---------------------------------------"
# Commands below are extracted from an OpenHPC install guide recipe and are intended for 
# execution on the master SMS host.
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Verify OpenHPC repository has been enabled before proceeding"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
yum -y -q install http://build.openhpc.community/OpenHPC:/1.3/CentOS_7/x86_64/ohpc-release-1.3-1.el7.x86_64.rpm
yum repolist | grep -q OpenHPC
if [ $? -ne 0 ];then
   echo "Error: OpenHPC repository must be enabled locally"
   exit 1
fi

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo " Disable firewall "
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
systemctl disable firewalld
systemctl stop firewalld

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo " Add baseline OpenHPC and provisioning services (Section 3.3)"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
yum -y -q groupinstall ohpc-base
yum -y -q groupinstall ohpc-warewulf
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Enable NTP services on SMS host"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
systemctl enable ntpd.service
echo "server ${ntp_server}" >> /etc/ntp.conf
systemctl restart ntpd

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Add resource management services slurm on master node (Section 3.4)"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
yum -y -q install ohpc-slurm-server
perl -pi -e "s/ControlMachine=\S+/ControlMachine=${sms_name}/" /etc/slurm/slurm.conf

# echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
# echo " Add InfiniBand support services on master node (Section 3.5)"
# echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
# yum -y -q groupinstall "InfiniBand Support"
# yum -y -q install infinipath-psm
# systemctl start rdma

# if [[ ${enable_ipoib} -eq 1 ]];then
    
#      echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
#      echo "Enable ib0"
#      echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
#      cp /opt/ohpc/pub/examples/network/centos/ifcfg-ib0 /etc/sysconfig/network-scripts
#      perl -pi -e "s/master_ipoib/${sms_ipoib}/" /etc/sysconfig/network-scripts/ifcfg-ib0
#      perl -pi -e "s/ipoib_netmask/${ipoib_netmask}/" /etc/sysconfig/network-scripts/ifcfg-ib0
#      ifup ib0
# fi

# echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
# echo "Optionally enable opensm subnet manager"
# echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
# if [[ ${enable_opensm} -eq 1 ]];then
#      yum -y -q install opensm
#      systemctl enable opensm
#      systemctl start opensm
# fi

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Complete basic Warewulf setup for master node (Section 3.6)"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
perl -pi -e "s/device = eth1/device = ${sms_eth_internal}/" /etc/warewulf/provision.conf
perl -pi -e "s/^\s+disable\s+= yes/ disable = no/" /etc/xinetd.d/tftp
ifconfig ${sms_eth_internal} ${sms_ip} netmask ${internal_netmask} up
systemctl restart xinetd
systemctl enable mariadb.service
systemctl restart mariadb
systemctl enable httpd.service
systemctl restart httpd
# if [ ! -z ${BOS_MIRROR+x} ]; then
#      export YUM_MIRROR=${BOS_MIRROR}
# fi

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Create compute image for Warewulf (Section 3.7.1)"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
export CHROOT=/opt/ohpc/admin/images/centos7.3
wwmkchroot centos-7 $CHROOT >/dev/null

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Add OpenHPC base components to compute image (Section 3.7.2)"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
yum -y -q --installroot=$CHROOT groupinstall ohpc-base-compute

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Add OpenHPC components to compute image (Section 3.7.2)"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
cp -p /etc/resolv.conf $CHROOT/etc/resolv.conf
# Add OpenHPC components to compute instance
yum -y -q --installroot=$CHROOT groupinstall ohpc-slurm-client
# yum -y -q --installroot=$CHROOT groupinstall "InfiniBand Support"
# yum -y -q --installroot=$CHROOT install infinipath-psm
# chroot $CHROOT systemctl enable rdma
yum -y -q --installroot=$CHROOT install ntp
yum -y -q --installroot=$CHROOT install kernel
yum -y -q --installroot=$CHROOT install lmod-ohpc

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Customize system configuration (Section 3.7.3)"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
wwinit database
wwinit ssh_keys
cat ~/.ssh/cluster.pub >> $CHROOT/root/.ssh/authorized_keys # Badi ako line
echo "${sms_ip}:/home /home nfs nfsvers=3,rsize=1024,wsize=1024,cto 0 0" >> $CHROOT/etc/fstab
echo "${sms_ip}:/opt/ohpc/pub /opt/ohpc/pub nfs nfsvers=3 0 0" >> $CHROOT/etc/fstab
echo "/home *(rw,no_subtree_check,fsid=10,no_root_squash)" >> /etc/exports
echo "/opt/ohpc/pub *(ro,no_subtree_check,fsid=11)" >> /etc/exports
exportfs -a
systemctl restart nfs
systemctl enable nfs-server
chroot $CHROOT systemctl enable ntpd
echo "server ${sms_ip}" >> $CHROOT/etc/ntp.conf

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Update basic slurm configuration if additional computes defined"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
if [ ${num_computes} -gt 4 ];then
   perl -pi -e "s/^NodeName=(\S+)/NodeName=${compute_prefix}[1-${num_computes}]/" /etc/slurm/slurm.conf
   perl -pi -e "s/^PartitionName=normal Nodes=(\S+)/PartitionName=normal Nodes=${compute_prefix}[1-${num_computes}]/" /etc/slurm/slurm.conf
   perl -pi -e "s/^NodeName=(\S+)/NodeName=${compute_prefix}[1-${num_computes}]/" $CHROOT/etc/slurm/slurm.conf
   perl -pi -e "s/^PartitionName=normal Nodes=(\S+)/PartitionName=normal Nodes=${compute_prefix}[1-${num_computes}]/" $CHROOT/etc/slurm/slurm.conf
fi

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Additional customizations (Section 3.7.4)"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
perl -pi -e 's/# End of file/\* soft memlock unlimited\n$&/s' /etc/security/limits.conf
perl -pi -e 's/# End of file/\* hard memlock unlimited\n$&/s' /etc/security/limits.conf
perl -pi -e 's/# End of file/\* soft memlock unlimited\n$&/s' $CHROOT/etc/security/limits.conf
perl -pi -e 's/# End of file/\* hard memlock unlimited\n$&/s' $CHROOT/etc/security/limits.conf

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Enable slurm pam module"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "account    required     pam_slurm.so" >> $CHROOT/etc/pam.d/sshd

# Enable Optional packages

if [[ ${enable_lustre_client} -eq 1 ]];then
     # Install Lustre client on master
     yum -y -q install lustre-client-ohpc lustre-client-ohpc-modules
     # Enable lustre in WW compute image
     yum -y -q --installroot=$CHROOT install lustre-client-ohpc lustre-client-ohpc-modules
     mkdir $CHROOT/mnt/lustre
     echo "${mgs_fs_name} /mnt/lustre lustre defaults,_netdev,localflock 0 0" >> $CHROOT/etc/fstab
     # Enable o2ib for Lustre
     echo "options lnet networks=o2ib(ib0)" >> /etc/modprobe.d/lustre.conf
     echo "options lnet networks=o2ib(ib0)" >> $CHROOT/etc/modprobe.d/lustre.conf
     # mount Lustre client on master
     mkdir /mnt/lustre
     mount -t lustre -o localflock ${mgs_fs_name} /mnt/lustre
fi

if [[ ${enable_nagios} -eq 1 ]];then
     # Install Nagios on master and vnfs image
     yum -y -q groupinstall ohpc-nagios
     yum -y -q --installroot=$CHROOT install nagios-plugins-all-ohpc nrpe-ohpc
     chroot $CHROOT systemctl enable nrpe
     perl -pi -e "s/^allowed_hosts=/# allowed_hosts=/" $CHROOT/etc/nagios/nrpe.cfg
     echo "nrpe 5666/tcp # NRPE"         >> $CHROOT/etc/services
     echo "nrpe : ${sms_ip}  : ALLOW"    >> $CHROOT/etc/hosts.allow
     echo "nrpe : ALL : DENY"            >> $CHROOT/etc/hosts.allow
     chroot $CHROOT /usr/sbin/useradd -c "NRPE user for the NRPE service" -d /var/run/nrpe -r -g nrpe -s /sbin/nologin nrpe
     chroot $CHROOT /usr/sbin/groupadd -r nrpe
     mv /etc/nagios/conf.d/services.cfg.example /etc/nagios/conf.d/services.cfg
     mv /etc/nagios/conf.d/hosts.cfg.example /etc/nagios/conf.d/hosts.cfg
     for ((i=0; i<$num_computes; i++)) ; do
        perl -pi -e "s/HOSTNAME$(($i+1))/${c_name[$i]}/ || s/HOST$(($i+1))_IP/${c_ip[$i]}/" \
        /etc/nagios/conf.d/hosts.cfg
     done
     perl -pi -e "s/ \/bin\/mail/ \/usr\/bin\/mailx/g" /etc/nagios/objects/commands.cfg
     perl -pi -e "s/nagios\@localhost/root\@${sms_name}/" /etc/nagios/objects/contacts.cfg
     echo command[check_ssh]=/usr/lib64/nagios/plugins/check_ssh localhost >> $CHROOT/etc/nagios/nrpe.cfg
     chkconfig nagios on
     systemctl start nagios
     chmod u+s `which ping`
fi

if [[ ${enable_ganglia} -eq 1 ]];then
     # Install Ganglia on master
     yum -y -q groupinstall ohpc-ganglia
     yum -y -q --installroot=$CHROOT install ganglia-gmond-ohpc
     cp /opt/ohpc/pub/examples/ganglia/gmond.conf /etc/ganglia/gmond.conf
     perl -pi -e "s/<sms>/${sms_name}/" /etc/ganglia/gmond.conf
     cp /etc/ganglia/gmond.conf $CHROOT/etc/ganglia/gmond.conf
     echo "gridname MySite" >> /etc/ganglia/gmetad.conf
     systemctl enable gmond
     systemctl enable gmetad
     systemctl start gmond
     systemctl start gmetad
     chroot $CHROOT systemctl enable gmond
     systemctl try-restart httpd
fi

if [[ ${enable_clustershell} -eq 1 ]];then
     # Install clustershell
     yum -y -q install clustershell-ohpc
     cd /etc/clustershell/groups.d
     mv local.cfg local.cfg.orig
     echo "adm: ${sms_name}" > local.cfg
     echo "compute: ${compute_prefix}[1-${num_computes}]" >> local.cfg
     echo "all: @adm,@compute" >> local.cfg
fi

if [[ ${enable_mrsh} -eq 1 ]];then
     # Install mrsh
     yum -y -q install mrsh-ohpc mrsh-rsh-compat-ohpc
     yum -y -q --installroot=$CHROOT install mrsh-ohpc mrsh-rsh-compat-ohpc mrsh-server-ohpc
     echo "mshell          21212/tcp                  # mrshd" >> /etc/services
     echo "mlogin            541/tcp                  # mrlogind" >> /etc/services
     chroot $CHROOT systemctl enable xinetd
fi

if [[ ${enable_genders} -eq 1 ]];then
     # Install genders
     yum -y -q install genders-ohpc
     echo -e "${sms_name}\tsms" > /etc/genders
     for ((i=0; i<$num_computes; i++)) ; do
        echo -e "${c_name[$i]}\tcompute,bmc=${c_bmc[$i]}"
     done >> /etc/genders
fi

# Optionally, enable conman and configure
if [[ ${enable_ipmisol} -eq 1 ]];then
     yum -y -q install conman-ohpc
     for ((i=0; i<$num_computes; i++)) ; do
        echo -n 'CONSOLE name="'${c_name[$i]}'" dev="ipmi:'${c_bmc[$i]}'" '
        echo 'ipmiopts="'U:${bmc_username},P:${IPMI_PASSWORD:-undefined},W:solpayloadsize'"'
     done >> /etc/conman.conf
     systemctl enable conman
     systemctl start conman
fi

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Configure rsyslog on SMS and computes (Section 3.7.4.10)"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
perl -pi -e "s/\\#\\\$ModLoad imudp/\\\$ModLoad imudp/" /etc/rsyslog.conf
perl -pi -e "s/\\#\\\$UDPServerRun 514/\\\$UDPServerRun 514/" /etc/rsyslog.conf
systemctl restart rsyslog
echo "*.* @${sms_ip}:514" >> $CHROOT/etc/rsyslog.conf
perl -pi -e "s/^\*\.info/\\#\*\.info/" $CHROOT/etc/rsyslog.conf
perl -pi -e "s/^authpriv/\\#authpriv/" $CHROOT/etc/rsyslog.conf
perl -pi -e "s/^mail/\\#mail/" $CHROOT/etc/rsyslog.conf
perl -pi -e "s/^cron/\\#cron/" $CHROOT/etc/rsyslog.conf
perl -pi -e "s/^uucp/\\#uucp/" $CHROOT/etc/rsyslog.conf

# ----------------------------
# Import files (Section 3.7.5)
# ----------------------------
wwsh file import /etc/passwd
wwsh file import /etc/group
wwsh file import /etc/shadow 
wwsh file import /etc/slurm/slurm.conf
wwsh file import /etc/munge/munge.key

# if [[ ${enable_ipoib} -eq 1 ]];then
#      wwsh file import /opt/ohpc/pub/examples/network/centos/ifcfg-ib0.ww
#      wwsh -y file set ifcfg-ib0.ww --path=/etc/sysconfig/network-scripts/ifcfg-ib0
# fi

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Assemble bootstrap image (Section 3.8)"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
export WW_CONF=/etc/warewulf/bootstrap.conf
echo "drivers += updates/kernel/" >> $WW_CONF
wwbootstrap `uname -r`
# Assemble VNFS
wwvnfs --chroot $CHROOT
# Add hosts to cluster
echo "GATEWAYDEV=${eth_provision}" > /tmp/network.$$
wwsh -y file import /tmp/network.$$ --name network
wwsh -y file set network --path /etc/sysconfig/network --mode=0644 --uid=0
for ((i=0; i<$num_computes; i++)) ; do
   wwsh -y node new ${c_name[i]} --ipaddr=${c_ip[i]} --hwaddr=${c_mac[i]} -D ${eth_provision}
done

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Add hosts to cluster (Cont.)"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
wwsh -y provision set "${compute_regex}" --vnfs=centos7.3 --bootstrap=`uname -r` --files=dynamic_hosts,passwd,group,shadow,slurm.conf,munge.key,network

# # Optionally, add arguments to bootstrap kernel
# if [[ ${enable_kargs} ]]; then
#    wwsh provision set "${compute_regex}" --kargs=${kargs}
# fi

# # Restart ganglia services to pick up hostfile changes
# if [[ ${enable_ganglia} -eq 1 ]];then
#   systemctl restart gmond
#   systemctl restart gmetad
# fi

# # Optionally, define IPoIB network settings (required if planning to mount Lustre over IB)
# if [[ ${enable_ipoib} -eq 1 ]];then
#      for ((i=0; i<$num_computes; i++)) ; do
#         wwsh -y node set ${c_name[$i]} -D ib0 --ipaddr=${c_ipoib[$i]} --netmask=${ipoib_netmask}
#      done
#      wwsh -y provision set "${compute_regex}" --fileadd=ifcfg-ib0.ww
# fi

systemctl restart dhcpd
wwsh pxe update

# # Optionally, enable console redirection 
# if [[ ${enable_ipmisol} -eq 1 ]];then
#      wwsh -y provision set "${compute_regex}" --kargs "${kargs} console=ttyS1,115200"
# fi

# echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
# # Boot compute nodes (Section 3.9)
# echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
# for ((i=0; i<${num_computes}; i++)) ; do
#    ipmitool -E -I lanplus -H ${c_bmc[$i]} -U ${bmc_username} chassis power reset
# done

# echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
# # Install Development Tools (Section 4.1)
# echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
# yum -y -q groupinstall ohpc-autotools
# yum -y -q install valgrind-ohpc
# yum -y -q install EasyBuild-ohpc
# yum -y -q install spack-ohpc
# yum -y -q install R_base-ohpc            

# echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
# # Install Compilers (Section 4.2)
# echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
# yum -y -q install gnu-compilers-ohpc

# echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
# # Install MPI Stacks (Section 4.3)
# echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
# if [[ ${enable_mpi_defaults} -eq 1 ]];then
#      yum -y -q install openmpi-gnu-ohpc mvapich2-gnu-ohpc mpich-gnu-ohpc
# elif [[ ${enable_mpi_opa} -eq 1 ]];then
#      yum -y -q install openmpi-psm2-gnu-ohpc mvapich2-psm2-gnu-ohpc
# fi

# echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
# # Install Performance Tools (Section 4.4)
# echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
# yum -y -q groupinstall ohpc-perf-tools-gnu
# yum -y -q install lmod-defaults-gnu-mvapich2-ohpc

# echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
# # Install 3rd Party Libraries and Tools (Section 4.6)
# echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
# yum -y -q groupinstall ohpc-serial-libs-gnu
# yum -y -q groupinstall ohpc-io-libs-gnu
# yum -y -q groupinstall ohpc-python-libs-gnu
# yum -y -q groupinstall ohpc-runtimes-gnu
# if [[ ${enable_mpi_defaults} -eq 1 ]];then
#      yum -y -q groupinstall ohpc-parallel-libs-gnu-mpich
#      yum -y -q groupinstall ohpc-parallel-libs-gnu-mvapich2
#      yum -y -q groupinstall ohpc-parallel-libs-gnu-openmpi
# elif [[ ${enable_mpi_opa} -eq 1 ]];then
#      yum -y -q groupinstall ohpc-parallel-libs-gnu-mvapich2
#      yum -y -q groupinstall ohpc-parallel-libs-gnu-openmpi
# fi

# echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
# echo "Install Optional Development Tools for use with Intel Parallel Studio (Section 4.7)"
# echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
# if [[ ${enable_intel_packages} -eq 1 ]];then
#      yum -y -q install intel-compilers-devel-ohpc
#      yum -y -q install intel-mpi-devel-ohpc
#      if [[ ${enable_mpi_opa} -eq 1 ]];then
#           yum -y -q install openmpi-psm2-intel-ohpc mvapich2-psm2-intel-ohpc
#      fi
#      yum -y -q groupinstall ohpc-serial-libs-intel
#      yum -y -q groupinstall ohpc-io-libs-intel
#      yum -y -q groupinstall ohpc-perf-tools-intel
#      yum -y -q groupinstall ohpc-python-libs-intel
#      yum -y -q groupinstall ohpc-runtimes-intel
#      yum -y -q groupinstall ohpc-parallel-libs-intel-mpich
#      yum -y -q groupinstall ohpc-parallel-libs-intel-mvapich2
#      yum -y -q groupinstall ohpc-parallel-libs-intel-openmpi
#      yum -y -q groupinstall ohpc-parallel-libs-intel-impi
# fi
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Resource Manager Startup (Section 5)"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
systemctl enable munge
systemctl enable slurmctld
systemctl start munge
systemctl start slurmctld
pdsh -w c[1-4] systemctl start slurmd
useradd -m shirshak
wwsh file resync passwd shadow group
sleep 2
pdsh -w c[1-4] /warewulf/bin/wwgetfiles 