$domain=$(az aro show -g voya-cluster-rg -n voya-sample-cluster --query clusterProfile.domain -o tsv)
$location=$(az aro show -g voya-cluster-rg -n voya-sample-cluster --query location -o tsv)
echo "OAuth callback URL: https://oauth-openshift.apps.$domain.$location.aroapp.io/oauth2callback/AAD"