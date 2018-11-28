# dcos-demo-1.12
Basic Enterprise DC/OS 1.12 Demo for mixed workloads including Spark, Kafka, and Kubernetes

## 1. Setup

Before starting the demo session, perform the following:

### a. Spin up an Enterprise DC/OS cluster using the Mesosphere DC/OS Universal Installer (Terraform templates).

Follow the instructions here: https://github.com/dcos/terraform-dcos

OR

Follow the instructions here: https://github.com/dmennell/quickAndDirtyDcosAwsDeployment

Make sure you include at least the following:

- 1 DC/OS Master Node
- 7 DC/OS Private Agent Nodes
- 2 DC/OS Public Agent Nodes

Also, make sure you deploy at least 4 CPU cores and 16MB of memory for the private and public agent nodes.

Finally, if you want to demonstrate Enterprise DC/OS's multiple region or availability zone capabilities, modify the Terraform templates (main.tf) to include multiple AZ and such.

### b. Login to the Enterprise DC/OS Dashboard

Point your web browser to DC/OS master node and login as the default superuser (bootstrapuser/deleteme). The master node Dashboard URL is:

    https://master node public ip address>

### c. Install the DC/OS command line interface (CLI)

In the DC/OS Dashboard, click on the drop down menu in the upper right side of hte Dashboard and follow the instructions for installing the DC/OS CLI binary for your OS.

Then run the cluster setup command:

    dcos cluster setup https://<master node public ip address>

NOTE: Make sure you use an HTTPS URL in the cluster setup command and not an HTTP URL.

Once the DC/OS CLI is installed, install some sub-commands:

    dcos package install --cli spark --yes

    dcos package install --cli kafka --yes

    dcos package install --cli kubernetes --yes

    dcos package install dcos-enterprise-cli --yes

### d. Prep the Cluster

To support launching Kubernetes clusters with DC/OS service accounts and SSL certificates, run the prep script that creates the base service account users and their signed certificates using the DC/OS certificate authority (CA).

    scripts/prep-cluster.sh

This script also attempts to install an Enteprise DC/OS license key if it finds the file:

    $HOME/scripts/license.txt

This is optional and is only needed if the license key used with the Terraform templates do not enable enough DC/OS nodes needed for this demo environment.

## 2. Demo

### a. DC/OS Overview

Show the main DC/OS Dashboard and talk about how DC/OS pools resources (CPU, GPU, Memory and Disk) and allocates them dynamically to services that are launched from the Catalog or Services panel.

Show the Nodes panel and show the servers that are being managed by DC/OS.

Show the Components panel and show how all the ecosystem components that are used to manage the cluster and how DC/OS automates the health of those low level components.

Show the Catalog panel and show how pre-packages applications and services can be launched easily from the package catalog and how customers can add their own packages using the DC/OS Universe github repo tools (see https://github.com/mesosphere/universe). Show the Settings->Package Reposities panel and discus how customers can add their own repos behind their firewall for private use.

### b. Demonstrate starting mixed workloads including:

- Jenkins
- Kafka
- Spark
- Cassandra

When Jenkins starts up, show the Jenkins Console and how customers can use the console or the Jenkins API to setup and manage build/test pipelines.

When the Spark dispatcher starts up, show the Spark console and discuss how multiple Spark environments (with different versions) can be launced for different teams and how DC/OS access control lists can be used to keep the teams separate.  You can run a sample Spark job buy using the 'dcos spark run' command as shown in the file:

    examples/spark-examples.txt

### c. Demonstrate starting multiple Kubernets Clusters

Discuss how Enterprise DC/OS supports "high density" kubernetes clusters and supports launching different versions of Kubernetes clusters to support different development teams. And how DC/OS uses the opensource version of Kubernetes and the kubectl package. And how DC/OS allows kubernetes control plan components and worker node components to be spread across cloud availability zones for HA reasons.

Use the DC/OS Dashboard Catalog panel to start the Kubernetes Control Plane Manager (the kubernetes package).

- Package: kubernetes
- Options:
    Service Name: kubernetes
    Service Account: kubernetes
    Service Account Secret: kubernetes/sa

Once the Kubernets control plane manager starts, use the DC/OS Dashboard Catalog panel to start two Kubernetes clusters. For the first Kubernetes cluster specify the service account user and secrets like this:

- Package: kubernetes-cluster
- Options:
    Service Name: kubernetes-cluster1
    Service Account: kubernetes-cluster1
    Service Account Secret: kubernetes-cluster1/sa
    Constrol Plane Placement: [["hostname", "UNIQUE"],["@zone", "GROUP_BY", "3"]]
    Private Node Count: 1
    Public Node Count: 1

Also, start a second Kubernetes cluster with a different name, service account user and a different 

- Package: kubernetes-cluster
- Options:
    Service Name: kubernetes-cluster2
    Service Account: kubernetes-cluster2
    Service Account Secret: kubernetes-cluster2/sa
    High Availability: TRUE
    Service Cidr: 10.101.0.0/16
    Constrol Plane Placement: [["hostname", "UNIQUE"],["@zone", "GROUP_BY", "3"]]
    Private Node Count: 1
    Public Node Count: 0

### d. Start the Kubernetes clusters' API Server proxy services

While the two Kubernetes clusters are launching, run the script that starts two HAProxy services on the DC/OS public agent nodes and redirect requests to the Kubernetes API Servers running on the DC/OS private agent nodes. Run the command:

    scripts/start-proxies.sh

### e. Demonstrate the Enterprise DC/OS features

While the two Kubernets clusters are launching, use the DC/OS Dashboard to show how DC/OS:

- Integrates with LDAP/AD servers
- Integrates with SAML 2.0 and OAuth2 authention servers
- Supports encrypted secrets

Create two user groups (mobile-apps and enterprise-apps), then create a user and add it to the mobile-apps group.

Add ACL rules to the mobile-apps group by copying the contents of:

    examples/acl-examples.txt

into the Permissions panel for the mobile-apps group.

Then log off as the super user and log in as the user you created. Show how many of the left side menu options are missing and try to start a MySQL package in the application group:

    /enterprise-apps/mysql

Show how DC/OS does not allow the user to start MySQL into that application group. Then change it to the group:

    /mobile-apps/mysql

And show how DC/OS allows that and by looking at the Services panel, how the MySQL package is "deploying".

### f. Demonstrate kubctl commands

Once the first Kubernetes cluster is launched (it should be quick since it didn't have HA enabled and only had 1 public and 1 private kubelet), demonstrate interacting with the Kubernetes cluster using the kubectl command.

Some example kubectl commands can be found in:

    examples/kubectl-examples.txt

If you want to demonstrate installing Helm and a Heml Chart, you can experiment with the commands found in:

    examples/helm-examples.txt

## 3. Summarize what you demonstrated

Summarize, for the audience, what you just demonstrated and how it can help customers deploy applications and services in a hybrid cloud environment with ease.

## 4. Shutdown the Services used in the Demo

To reset the DC/OS cluster to a new state, run the script:

    scripts/reset-demo.sh


