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

Make sure you deploy at least 4 CPU cores and 16MB of memory for the private and public agent nodes.

### b. Login to the Enterprise DC/OS Dashboard

Point your web browser to https://<master node public ip address> and login as the default superuser (bootstrapuser/deleteme).

### c. Install the DC/OS command line interface (CLI)

In the DC/OS Dashboard, click on the drop down menu in the upper right side of hte Dashboard and follow the instructions for installing the DC/OS CLI binary for your OS.

Then run the cluster setup command:

    dcos cluster setup https://<master node public ip address>

    NOTE: Make sure you use an HTTPS URL in the cluster setup command and not an HTTP URL.

### d. To support launching Kubernetes clusters with DC/OS service accounts and SSL certificates, run the prep script that creates the base service account users and their signed certificates using the DC/OS certificate authority (CA).

    scripts/prep-cluster.sh




