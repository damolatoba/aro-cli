$domain = $(az aro show -g aro-rg -n aro-cluster --query clusterProfile.domain -o tsv)
$location =$(az aro show -g aro-rg -n aro-cluster --query location -o tsv)
$apiServer =$(az aro show -g aro-rg -n aro-cluster --query apiserverProfile.url -o tsv)
$webConsole =$(az aro show -g aro-rg -n aro-cluster --query consoleProfile.url -o tsv)

$oauthCallbackURL= 'https://oauth-openshift.apps.'+$domain+'.'+$location+'.aroapp.io/oauth2callback/AAD'

Write-Output $oauthCallbackURL



az aro delete --resource-group aro-cluster-rg --name aro-cluster