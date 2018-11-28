#!/bin/bash
#
# SCRIPT: prep-demo.sh
#

# Check if the DC/OS CLI command is installed
result=$(which dcos)
if [ "$result" == "" ]
then
    echo ""
    echo " ERROR: The DC/OS CLI command binary is not installed. Please install it. "
    echo ""
    exit 1
fi

# Check if the DC/OS CLI command is working against a working cluster
result=$(dcos node 2>&1)

if [[ "$result" == *"is unreachable"* ]]
then
    echo ""
    echo " ERROR: DC/OS Master Node is unreachable. Is the DC/OS CLI configured correctly"
    echo ""
    echo "        Run:   dcos cluster setup <master node ip>"
    exit 1
fi

echo

# Check if master node URL is https and not http
result=$(dcos config show core.dcos_url)

if [[ "$result" == *"http://"* ]]
then
    echo
    echo " ERROR: Your DC/OS CLI command is NOT using HTTPS. Please re-run the 'dcos cluster setup' command like this:"
    echo
    echo "        dcos cluster setup https://<master node ip addr>"
    echo
    exit 1
fi

echo
echo " Checking for license key  file in ~/scripts/license.txt"
if [ -f ~/scripts/license.txt ]
then
    echo
    echo " Found license key file"
else
    echo
    echo " ERROR: Could not find the Ent. DC/OS license key file: ~/scripts/license.txt"
    echo "        Please download the license key file and place it there."
    exit 1

fi

# Install the enterprise CLI so we can create service account users and secrets
echo " Installing dcos-enterprise-cli package "
dcos package install --cli dcos-enterprise-cli --yes > /dev/null 2>&1

echo
echo " Getting current license status"
dcos license status

echo
echo " Updating the license key with ~/scripts/license.txt"
dcos license renew  ~/scripts/license.txt
dcos license status

# Create the service account user for kubernetes control plane manager
echo
echo " Creating SSL Cert and Service Account User for kubernetes control plane manager"
rm -rf /tmp/private-key0.pem /tmp/public-key0.pem > /dev/null 2>&1
dcos security org service-accounts keypair /tmp/private-key0.pem /tmp/public-key0.pem
dcos security org service-accounts create -p /tmp/public-key0.pem -d 'Kubernetes control plane manager service account' kubernetes
dcos security secrets create-sa-secret /tmp/private-key0.pem kubernetes kubernetes/sa

# Create the access control list privs for the kubernetes control plane manager
echo
echo " Adding privilages to service account user the kubernetes control plane manager"
dcos security org users grant kubernetes  dcos:mesos:master:framework:role:kubernetes-role create
dcos security org users grant kubernetes  dcos:mesos:master:task:user:root create
dcos security org users grant kubernetes  dcos:mesos:agent:task:user:root create
dcos security org users grant kubernetes  dcos:mesos:master:reservation:role:kubernetes-role create
dcos security org users grant kubernetes  dcos:mesos:master:reservation:principal:kubernetes delete
dcos security org users grant kubernetes  dcos:mesos:master:volume:role:kubernetes-role create
dcos security org users grant kubernetes  dcos:mesos:master:volume:principal:kubernetes delete
dcos security org users grant kubernetes  dcos:secrets:default:/kubernetes/* full
dcos security org users grant kubernetes  dcos:secrets:list:default:/kubernetes read
dcos security org users grant kubernetes  dcos:adminrouter:ops:ca:rw full
dcos security org users grant kubernetes  dcos:adminrouter:ops:ca:ro full
dcos security org users grant kubernetes  dcos:mesos:master:framework:role:slave_public/kubernetes-role create
dcos security org users grant kubernetes  dcos:mesos:master:framework:role:slave_public/kubernetes-role read
dcos security org users grant kubernetes  dcos:mesos:master:reservation:role:slave_public/kubernetes-role create
dcos security org users grant kubernetes  dcos:mesos:master:volume:role:slave_public/kubernetes-role create
dcos security org users grant kubernetes  dcos:mesos:master:framework:role:slave_public read
dcos security org users grant kubernetes  dcos:mesos:agent:framework:role:slave_public read

# Create the service account user for kubernetes cluster1
echo
echo " Creating SSL Cert and Service Account User for kubernetes-cluster1"
rm -rf /tmp/private-key1.pem /tmp/public-key1.pem > /dev/null 2>&1
dcos security org service-accounts keypair /tmp/private-key1.pem /tmp/public-key1.pem
dcos security org service-accounts create -p /tmp/public-key1.pem -d 'Kubernetes cluster 1 service account' kubernetes-cluster1
dcos security secrets create-sa-secret /tmp/private-key1.pem kubernetes-cluster1 kubernetes-cluster1/sa

# Create the access control list privs for cluster1
echo
echo " Adding privilages to service account user kubernetes-cluster1"
dcos security org users grant kubernetes-cluster1  dcos:mesos:master:framework:role:kubernetes-cluster1-role create
dcos security org users grant kubernetes-cluster1  dcos:mesos:master:task:user:root create
dcos security org users grant kubernetes-cluster1  dcos:mesos:agent:task:user:root create
dcos security org users grant kubernetes-cluster1  dcos:mesos:master:reservation:role:kubernetes-cluster1-role create
dcos security org users grant kubernetes-cluster1  dcos:mesos:master:reservation:principal:kubernetes-cluster1 delete
dcos security org users grant kubernetes-cluster1  dcos:mesos:master:volume:role:kubernetes-cluster1-role create
dcos security org users grant kubernetes-cluster1  dcos:mesos:master:volume:principal:kubernetes-cluster1 delete
dcos security org users grant kubernetes-cluster1  dcos:secrets:default:/kubernetes-cluster1/* full
dcos security org users grant kubernetes-cluster1  dcos:secrets:list:default:/kubernetes-cluster1 read
dcos security org users grant kubernetes-cluster1  dcos:adminrouter:ops:ca:rw full
dcos security org users grant kubernetes-cluster1  dcos:adminrouter:ops:ca:ro full
dcos security org users grant kubernetes-cluster1  dcos:mesos:master:framework:role:slave_public/kubernetes-cluster1-role create
dcos security org users grant kubernetes-cluster1  dcos:mesos:master:framework:role:slave_public/kubernetes-cluster1-role read
dcos security org users grant kubernetes-cluster1  dcos:mesos:master:reservation:role:slave_public/kubernetes-cluster1-role create
dcos security org users grant kubernetes-cluster1  dcos:mesos:master:volume:role:slave_public/kubernetes-cluster1-role create
dcos security org users grant kubernetes-cluster1  dcos:mesos:master:framework:role:slave_public read
dcos security org users grant kubernetes-cluster1  dcos:mesos:agent:framework:role:slave_public read

# Create the service account user for kubernetes cluster2
echo
echo " Creating SSL Cert and Service Account User for kubernetes-cluster2"
rm -rf /tmp/private-key2.pem /tmp/public-key2.pem
dcos security org service-accounts keypair /tmp/private-key2.pem /tmp/public-key2.pem
dcos security org service-accounts create -p /tmp/public-key2.pem -d 'Kubernetes cluster 2 service account' kubernetes-cluster2
dcos security secrets create-sa-secret /tmp/private-key2.pem kubernetes-cluster2 kubernetes-cluster2/sa

# Create the access control list privs for cluster2
echo
echo " Adding privilages to service account user kubernetes-cluster2"
dcos security org users grant kubernetes-cluster2  dcos:mesos:master:framework:role:kubernetes-cluster2-role create
dcos security org users grant kubernetes-cluster2  dcos:mesos:master:task:user:root create
dcos security org users grant kubernetes-cluster2  dcos:mesos:agent:task:user:root create
dcos security org users grant kubernetes-cluster2  dcos:mesos:master:reservation:role:kubernetes-cluster2-role create
dcos security org users grant kubernetes-cluster2  dcos:mesos:master:reservation:principal:kubernetes-cluster2 delete
dcos security org users grant kubernetes-cluster2  dcos:mesos:master:volume:role:kubernetes-cluster2-role create
dcos security org users grant kubernetes-cluster2  dcos:mesos:master:volume:principal:kubernetes-cluster2 delete
dcos security org users grant kubernetes-cluster2  dcos:secrets:default:/kubernetes-cluster2/* full
dcos security org users grant kubernetes-cluster2  dcos:secrets:list:default:/kubernetes-cluster2 read
dcos security org users grant kubernetes-cluster2  dcos:adminrouter:ops:ca:rw full
dcos security org users grant kubernetes-cluster2  dcos:adminrouter:ops:ca:ro full
dcos security org users grant kubernetes-cluster2  dcos:mesos:master:framework:role:slave_public/kubernetes-cluster2-role create
dcos security org users grant kubernetes-cluster2  dcos:mesos:master:framework:role:slave_public/kubernetes-cluster2-role read
dcos security org users grant kubernetes-cluster2  dcos:mesos:master:reservation:role:slave_public/kubernetes-cluster2-role create
dcos security org users grant kubernetes-cluster2  dcos:mesos:master:volume:role:slave_public/kubernetes-cluster2-role create
dcos security org users grant kubernetes-cluster2  dcos:mesos:master:framework:role:slave_public read
dcos security org users grant kubernetes-cluster2  dcos:mesos:agent:framework:role:slave_public read

# end of script
