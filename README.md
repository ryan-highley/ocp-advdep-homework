#ocp-advdep-homework

##Commands

###Get LDAP server CA cert
wget http://ipa.shared.example.opentlc.com/ipa/config/ca.crt -O /root/ipa-ca.crt

###Use masters[0] k8s config for system:admin with oc
ansible masters[0] -b -m fetch -a "src=/root/.kube/config dest=/root/.kube/config flat=yes"

