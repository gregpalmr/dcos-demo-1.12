#!/bin/bash
#
# SCRIPT: startall.sh
#
# Use this script if you want to stall 2 kubernetes clusters in advance
#

# Get path to the Prep Cluster script
prep_script=$(find . |grep prep-demo.sh)

if [ "$prep_script" == "" ]
then
    echo ""
    echo " ERROR: Cannot find the prep-demo.sh script. Exiting."
    echo
    exit 1
fi

# Get path to  the start proxies script 
proxies_script=$(find . | grep start-proxies.sh)
if [ "$proxies_script" == "" ]
then
    echo ""
    echo " ERROR: Cannot find the start-proxies.sh script. Exiting."
    echo
    exit 1
fi


echo
echo " Running script: $prep_script "
echo
bash $prep_script

echo 
echo " Starting the DC/OS Kubernetes Control Plane manager""
echo
dcos package install kubernetes --package-version=2.0.0-1.12.1 --yes

echo
echo " Waiting for the Kubernetes Control Plane Manager package to start. "
while true
do
    task_status=$(dcos task |grep mesosphere-kubernetes-engine-0 | awk '{print $4}')

    if [ "$task_status" != "R" ]
    then
        printf "."
    else
        echo " Kubernetes Control Plane Manager is running."
        break
    fi
    sleep 10
done

echo
echo " Starting the first Kubernetes cluster (K8s version 1.12.2) "
echo

cat > /tmp/kubernetes-cluster1-options.json <<EOF
{
  "service": {
    "name": "kubernetes-cluster1",
    "service_account": "kubernetes-cluster1",
    "service_account_secret": "kubernetes-cluster1/sa"
  },
  "kubernetes": {
    "high_availability": false,
    "service_cidr": "10.100.0.0/16",
    "private_node_count": 2,
    "public_node_count": 1
  }
}
EOF

dcos kubernetes cluster create --options=/tmp/kubernetes-cluster1-options.json --package-version=2.0.1-1.12.2 --yes

echo
echo " Starting the second Kubernetes cluster (K8s version 1.12.1 with HA Mode) "
echo

cat > /tmp/kubernetes-cluster2-options.json <<EOF
{
  "service": {
    "name": "kubernetes-cluster2",
    "service_account": "kubernetes-cluster2",
    "service_account_secret": "kubernetes-cluster2/sa"
  },
  "kubernetes": {
    "high_availability": true,
    "service_cidr": "10.101.0.0/16",
    "private_node_count": 2,
    "public_node_count": 1
  }
}
EOF

dcos kubernetes cluster create --options=/tmp/kubernetes-cluster2-options.json --package-version=2.0.0-1.12.1 --yes

echo
echo " Waiting for Kubernetes cluster 1 to start. "
while true
do
    task_status=$(dcos kubernetes manager plan status deploy --name=kubernetes-cluster1 | grep -v COMPLETE)

    if [ "$task_status" != "" ]
    then
        printf "."
    else
        echo " Kubernetes Cluster 1 is running."
        break
    fi
    sleep 10
done

echo
echo " Running script: $proxies_script "
echo
bash $proxies_script


echo
echo " Waiting for Kubernetes cluster 2 to start. "
while true
do
    task_status=$(dcos kubernetes manager plan status deploy --name=kubernetes-cluster2 | grep -v COMPLETE)

    if [ "$task_status" != "" ]
    then
        printf "."
    else
        echo " Kubernetes Cluster 2 is running."
        break
    fi
    sleep 10
done

# end of script
