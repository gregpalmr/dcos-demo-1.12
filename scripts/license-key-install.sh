#!/bin/bash
#
# SCRIPT: license-key-install.sh
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
echo " Checking for license key  file in ~/scripts/license.txt"
if [ -f ~/scripts/license.txt ]
then
    echo
    echo " Found license key file"
else
    echo
    echo " ERROR: Could not find license key file: ~/scripts/license.txt"
    exit 1

fi

echo

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

# End of script
