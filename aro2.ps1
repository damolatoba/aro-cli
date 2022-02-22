## Connect to ARO cluster

$LOCATION = 'eastus'                 # the location of your cluster
$RESOURCEGROUP = 'aro-rg'            # the name of the resource group where you want to create your cluster
$CLUSTER = 'aro-cluster'                 # the name of your cluster

##az aro list-credentials --name $CLUSTER --resource-group $RESOURCEGROUP
$clusterCredentials = az aro list-credentials --name $CLUSTER --resource-group $RESOURCEGROUP | ConvertFrom-Json
$adminuser = $($clusterCredentials.kubeadminUsername)
$adminpass = $($clusterCredentials.kubeadminPassword)

$apiServer=$(az aro show -g $RESOURCEGROUP -n $CLUSTER --query apiserverProfile.url -o tsv)

$clusterurl = $(az aro show --name $CLUSTER --resource-group $RESOURCEGROUP --query "consoleProfile.url" -o tsv)

Write-Output $clusterurl
Write-Output $apiServer
Write-Output $adminpass

oc login 'https://api.bpkdv0x3.eastus.aroapp.io:6443/' --username=kubeadmin --password=IsZ53-mWGWC-nCj9i-Zzwch