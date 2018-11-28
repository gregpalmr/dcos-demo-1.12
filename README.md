# dcos-demo-1.12
Basic Enterprise DC/OS 1.12 Demo for mixed workloads including Spark, Kafka, and Kubernetes

## 1. Setup

Before starting the demo session, perform the following:

### Spin up an Enterprise DC/OS cluster using the Mesosphere DC/OS Universal Installer (Terraform Templates).

Follow the instructions here: https://github.com/dcos/terraform-dcos

OR

Follow the instructions here: https://github.com/dmennell/quickAndDirtyDcosAwsDeployment

Make sure you include at least the following:

1 DC/OS Master Node
7 DC/OS Private Agent Nodes
2 DC/OS Public Agent Nodes

Make sure you use 4 CPU cores and 16MB of memory for the private and public agent nodes.







