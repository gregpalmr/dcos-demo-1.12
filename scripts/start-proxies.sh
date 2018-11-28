#!/bin/bash
#
# SCRIPT: start-proxies.sh
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

# Check if the DC/OS CLI is correctly logged into a cluster
if [[ "$result" == *"Authentication failed"* ]]
then
    echo
    echo " ERROR: Not logged in. Please log into the DC/OS cluster with the "
    echo " command 'dcos auth login'"
    echo " Exiting."
    echo
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


echo " Installing the DC/OS CLI Kubernetes subcommand"
dcos package install --cli kubernetes --yes  > /dev/null 2>&1

echo
echo " Starting HAProxy service for the Kubernetes API server for kubernetes-cluster1 and kubernetes-cluster2 "
echo

dcos marathon app add resources/cluster1-haproxy-marathon.json > /dev/null 2>&1
sleep 2
dcos marathon app add resources/cluster2-haproxy-marathon.json > /dev/null 2>&1
sleep 2

echo
echo " Getting IP Addresses of the DC/OS agents running the HAProxy services "
echo "     NOTE: You must run ssh-add to add your DC/OS cluster's SSH key to your cache for this to work"
echo

HAPROXY1_PUB_IP=$(priv_ip=$(dcos task kubernetes-cluster1-haproxy | grep -v HOST | awk '{print $2}') && dcos node ssh --option StrictHostKeyChecking=no --option LogLevel=quiet --master-proxy --private-ip=$priv_ip "curl http://169.254.169.254/latest/meta-data/public-ipv4"); echo && echo "HAPROXY1_PUB_IP:   $HAPROXY1_PUB_IP"

HAPROXY2_PUB_IP=$(priv_ip=$(dcos task kubernetes-cluster2-haproxy | grep -v HOST | awk '{print $2}') && dcos node ssh --option StrictHostKeyChecking=no --option LogLevel=quiet --master-proxy --private-ip=$priv_ip "curl http://169.254.169.254/latest/meta-data/public-ipv4"); echo && echo "HAPROXY2_PUB_IP:   $HAPROXY2_PUB_IP"


# Setup kubectl to use the 
echo
echo " Setting up kubectl to use the proxies "

rm -rf ~/.kube.backup
mv ~/.kube ~/.kube.backup

dcos kubernetes cluster kubeconfig \
    --insecure-skip-tls-verify \
    --context-name=kubernetes-cluster2 \
    --cluster-name=kubernetes-cluster2 \
    --apiserver-url=https://${HAPROXY2_PUB_IP}:6444

dcos kubernetes cluster kubeconfig \
    --insecure-skip-tls-verify \
    --context-name=kubernetes-cluster1 \
    --cluster-name=kubernetes-cluster1 \
    --apiserver-url=https://${HAPROXY1_PUB_IP}:6443

echo
echo " kubectl setup for 2 Kubernetes clusters. To switch contexts, use these commands:"
echo
echo " kubectl config get-contexts"
echo " kubectl config use-context kubernetes-cluster2"
echo " kubectl config use-context kubernetes-cluster1"
echo

# End of script
