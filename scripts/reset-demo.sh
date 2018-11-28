#!/bin/bash
#
# SCRIPT: reset-demo.sh
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

# Install the enterprise CLI so we can create service account users and secrets
echo " Installing dcos-enterprise-cli package "
dcos package install --cli dcos-enterprise-cli --yes > /dev/null 2>&1


# Remove the Kubernetes API Server proxies
echo
echo " Removing Kubernetes API Server proxies"
dcos marathon app remove /kube-api-proxies/kubernetes-cluster1-haproxy
dcos marathon app remove /kube-api-proxies/kubernetes-cluster2-haproxy
dcos marathon group remove  /kube-api-proxies

# Remove Kubernetes cluster1 and cluster2
echo
echo " Destroying Kubernetes Clusters "
dcos kubernetes cluster delete  --cluster-name=kubernetes-cluster2 --yes
sleep 2
dcos kubernetes cluster delete  --cluster-name=kubernetes-cluster1 --yes
sleep 60

echo
echo " Uninstalling Kubernetes Control Plane Manager package "
dcos package uninstall --app-id=kubernetes kubernetes --yes
sleep 20

# Remove the secret and service account user for kubernetes cluster1
echo
echo " Removing secret and service account user for kubernetes-cluster1"
rm -rf /tmp/private-key1.pem /tmp/public-key1.pem > /dev/null 2>&1
dcos security secrets delete kubernetes-cluster1/sa > /dev/null 2>&1
dcos security secrets delete kubernetes-cluster1/admin_crt__tmp
dcos security secrets delete kubernetes-cluster1/admin_key__tmp
dcos security secrets delete kubernetes-cluster1/aggregator_ca_crt
dcos security secrets delete kubernetes-cluster1/aggregator_ca_crt__tmp
dcos security secrets delete kubernetes-cluster1/aggregator_ca_private_key
dcos security secrets delete kubernetes-cluster1/aggregator_ca_public_key
dcos security secrets delete kubernetes-cluster1/ca_crt__tmp
dcos security secrets delete kubernetes-cluster1/control_plane_kubelet_0_crt__tmp
dcos security secrets delete kubernetes-cluster1/control_plane_kubelet_0_private_key__tmp
dcos security secrets delete kubernetes-cluster1/control_plane_kubelet_1_crt__tmp
dcos security secrets delete kubernetes-cluster1/control_plane_kubelet_1_private_key__tmp
dcos security secrets delete kubernetes-cluster1/control_plane_kubelet_2_crt__tmp
dcos security secrets delete kubernetes-cluster1/control_plane_kubelet_2_private_key__tmp
dcos security secrets delete kubernetes-cluster1/etcd_chain__tmp
dcos security secrets delete kubernetes-cluster1/etcd_private_key__tmp
dcos security secrets delete kubernetes-cluster1/internal_ca_crt
dcos security secrets delete kubernetes-cluster1/internal_ca_crt__tmp
dcos security secrets delete kubernetes-cluster1/internal_ca_private_key
dcos security secrets delete kubernetes-cluster1/internal_ca_private_key__tmp
dcos security secrets delete kubernetes-cluster1/internal_ca_public_key
dcos security secrets delete kubernetes-cluster1/kube_apiserver_chain__tmp
dcos security secrets delete kubernetes-cluster1/kube_apiserver_private_key__tmp
dcos security secrets delete kubernetes-cluster1/kube_controller_manager_crt__tmp
dcos security secrets delete kubernetes-cluster1/kube_controller_manager_private_key__tmp
dcos security secrets delete kubernetes-cluster1/kube_proxy_crt__tmp
dcos security secrets delete kubernetes-cluster1/kube_proxy_private_key__tmp
dcos security secrets delete kubernetes-cluster1/kube_scheduler_crt__tmp
dcos security secrets delete kubernetes-cluster1/kube_scheduler_private_key__tmp
dcos security secrets delete kubernetes-cluster1/kubelet-tls-bootstrapping-public-token__tmp
dcos security secrets delete kubernetes-cluster1/kubelet-tls-bootstrapping-secret-token__tmp
dcos security secrets delete kubernetes-cluster1/kubelet_resource_watchdog_crt__tmp
dcos security secrets delete kubernetes-cluster1/kubelet_resource_watchdog_private_key__tmp
dcos security secrets delete kubernetes-cluster1/kubelet_tls_bootstrapping_public_token
dcos security secrets delete kubernetes-cluster1/kubelet_tls_bootstrapping_secret_token
dcos security secrets delete kubernetes-cluster1/kubernetes_dashboard_chain__tmp
dcos security secrets delete kubernetes-cluster1/kubernetes_dashboard_private_key__tmp
dcos security secrets delete kubernetes-cluster1/metrics_server_chain__tmp
dcos security secrets delete kubernetes-cluster1/metrics_server_private_key__tmp
dcos security secrets delete kubernetes-cluster1/proxy_client_chain__tmp
dcos security secrets delete kubernetes-cluster1/proxy_client_private_key__tmp
dcos security secrets delete kubernetes-cluster1/service_account_private_key
dcos security secrets delete kubernetes-cluster1/service_account_private_key__tmp
dcos security secrets delete kubernetes-cluster1/service_account_public_key
dcos security org service-accounts delete kubernetes-cluster1 > /dev/null 2>&1

# Remove the secret and service account user for kubernetes cluster2 
echo
echo " Removing secret and service account user for kubernetes-cluster2"
rm -rf /tmp/private-key2.pem /tmp/public-key2.pem > /dev/null 2>&1
dcos security secrets delete kubernetes-cluster2/sa > /dev/null 2>&1
dcos security secrets delete kubernetes-cluster2/admin_crt__tmp
dcos security secrets delete kubernetes-cluster2/admin_key__tmp
dcos security secrets delete kubernetes-cluster2/aggregator_ca_crt
dcos security secrets delete kubernetes-cluster2/aggregator_ca_crt__tmp
dcos security secrets delete kubernetes-cluster2/aggregator_ca_private_key
dcos security secrets delete kubernetes-cluster2/aggregator_ca_public_key
dcos security secrets delete kubernetes-cluster2/ca_crt__tmp
dcos security secrets delete kubernetes-cluster2/control_plane_kubelet_0_crt__tmp
dcos security secrets delete kubernetes-cluster2/control_plane_kubelet_0_private_key__tmp
dcos security secrets delete kubernetes-cluster2/etcd_chain__tmp
dcos security secrets delete kubernetes-cluster2/etcd_private_key__tmp
dcos security secrets delete kubernetes-cluster2/internal_ca_crt
dcos security secrets delete kubernetes-cluster2/internal_ca_crt__tmp
dcos security secrets delete kubernetes-cluster2/internal_ca_private_key
dcos security secrets delete kubernetes-cluster2/internal_ca_private_key__tmp
dcos security secrets delete kubernetes-cluster2/internal_ca_public_key
dcos security secrets delete kubernetes-cluster2/kube_apiserver_chain__tmp
dcos security secrets delete kubernetes-cluster2/kube_apiserver_private_key__tmp
dcos security secrets delete kubernetes-cluster2/kube_controller_manager_crt__tmp
dcos security secrets delete kubernetes-cluster2/kube_controller_manager_private_key__tmp
dcos security secrets delete kubernetes-cluster2/kube_proxy_crt__tmp
dcos security secrets delete kubernetes-cluster2/kube_proxy_private_key__tmp
dcos security secrets delete kubernetes-cluster2/kube_scheduler_crt__tmp
dcos security secrets delete kubernetes-cluster2/kube_scheduler_private_key__tmp
dcos security secrets delete kubernetes-cluster2/kubelet-tls-bootstrapping-public-token__tmp
dcos security secrets delete kubernetes-cluster2/kubelet-tls-bootstrapping-secret-token__tmp
dcos security secrets delete kubernetes-cluster2/kubelet_resource_watchdog_crt__tmp
dcos security secrets delete kubernetes-cluster2/kubelet_resource_watchdog_private_key__tmp
dcos security secrets delete kubernetes-cluster2/kubelet_tls_bootstrapping_public_token
dcos security secrets delete kubernetes-cluster2/kubelet_tls_bootstrapping_secret_token
dcos security secrets delete kubernetes-cluster2/kubernetes_dashboard_chain__tmp
dcos security secrets delete kubernetes-cluster2/kubernetes_dashboard_private_key__tmp
dcos security secrets delete kubernetes-cluster2/metrics_server_chain__tmp
dcos security secrets delete kubernetes-cluster2/metrics_server_private_key__tmp
dcos security secrets delete kubernetes-cluster2/proxy_client_chain__tmp
dcos security secrets delete kubernetes-cluster2/proxy_client_private_key__tmp
dcos security secrets delete kubernetes-cluster2/service_account_private_key
dcos security secrets delete kubernetes-cluster2/service_account_private_key__tmp
dcos security secrets delete kubernetes-cluster2/service_account_public_key
dcos security org service-accounts delete kubernetes-cluster2 > /dev/null 2>&1

echo
echo " Removing Cassandra"
dcos package uninstall cassandra --yes

echo
echo " Removing Kafka"
dcos package uninstall kafka --yes

echo
echo " Removing Spark"
dcos package uninstall spark --yes

echo
echo " Removing hdfs"
dcos package uninstall hdfs --yes

echo
echo " Removing ~/.kube directory "
rm -rf ~/.kube 


