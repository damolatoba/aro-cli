$resource_group = "voya-cluster-rg"
$aro_cluster = "voya-sample-cluster"

$domain = $(az aro show -g $resource_group -n $aro_cluster --query clusterProfile.domain -o tsv)
$location =$(az aro show -g $resource_group -n $aro_cluster --query location -o tsv)
$apiServer =$(az aro show -g $resource_group -n $aro_cluster --query apiserverProfile.url -o tsv)
$webConsole =$(az aro show -g $resource_group -n $aro_cluster --query consoleProfile.url -o tsv)

$oauthCallbackURL='https://oauth-openshift.apps.'+$domain+'.'+$location+'.aroapp.io/oauth2callback/AAD'

echo $oauthCallbackURL

#az aro show --name voya-sample-cluster --resource-group voya-cluster-rg --query "consoleProfile.url" -o tsv

#oc create secret docker-registry acr-secret --docker-server=voyacontainerregistry1.azurecr.io --docker-username=voyacontainerregistry1 --docker-password=0OazjxkyUfXt/duCLje5td+gfkVj7tVd --docker-email=unused