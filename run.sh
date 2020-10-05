#!/bin/bash
NSO_VERSION=${NSO_VERSION}
VERBOSITY="normal"

PASSWD="$(printenv DOCKPWD)"

mkdir /var/run/sshd
echo "root":"$PASSWD" | chpasswd
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

echo "export VISIBLE=now" >> /etc/profile

service ssh start
service ssh status

cd /ncs-run
make ncs
ls
cd packages
git clone https://github.com/NSO-developer/drned-xmnr
ls
cd ..
chmod 777 packages
make packages
make start
ncs --status
/nso/bin/ncs_cli -n -u admin -C << EOF
config
drned-xmnr log-detail cli overview
drned-xmnr xmnr-directory ./xmnr
python-vm logging level level-debug
commit
exit
exit
EOF
/bin/bash
