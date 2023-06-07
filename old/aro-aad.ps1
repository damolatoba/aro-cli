az account set --subscription 549cf74a-fcb0-49d2-8a63-968ea8b2b1f8

$resource_group = "voya-cluster-rg"
$aro_cluster = "voya-sample-cluster"

$domain = $(az aro show -g $resource_group -n $aro_cluster --query clusterProfile.domain -o tsv)
$location =$(az aro show -g $resource_group -n $aro_cluster --query location -o tsv)
$apiServer =$(az aro show -g $resource_group -n $aro_cluster --query apiserverProfile.url -o tsv)
$webConsole =$(az aro show -g $resource_group -n $aro_cluster --query consoleProfile.url -o tsv)

$oauthCallbackURL='https://oauth-openshift.apps.'+$domain+'.'+$location+'.aroapp.io/oauth2callback/AAD'

#echo $oauthCallbackURL

$tenant_id=$(az account show --query tenantId -o tsv)

$client_secret = 'OlodeStone@2019'

$app_id=$(az ad app create --display-name aro-auth --reply-urls $oauthCallbackURL --password $client_secret)

New-Item -Path . -Name "manifest.json" -ItemType "file"

Add-Content -Path .\manifest.json -Value '[{
  "name": "upn",
  "source": null,
  "essential": false,
  "additionalProperties": []
},
{
"name": "email",
  "source": null,
  "essential": false,
  "additionalProperties": []
}]'

#az ad app update --set optionalClaims.idToken=@manifest.json --id $app_id

az ad app update --id $app_id --optional-claims.idToken=@manifest.json
az ad app permission add --id $app_id --api 00000002-0000-0000-c000-000000000000 --api-permissions 311a71cc-e848-46a1-bdf8-97ff7156d8e6=Scope

$kubeadmin_password = $(az aro list-credentials --name $aro_cluster --resource-group $resource_group --query kubeadminPassword --output tsv)

oc login $apiServer -u kubeadmin -p $kubeadmin_password

oc create secret generic openid-client-secret-azuread --namespace openshift-config --from-literal=clientSecret=$client_secret

New-Item -Path . -Name "oidc.yaml" -ItemType "file"

Add-Content -Path .\oidc.yaml -Value 'apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  name: cluster
spec:
  identityProviders:
  - name: AAD
    mappingMethod: claim
    type: OpenID
    openID:'
Add-Content -Path .\oidc.yaml -Value "      clientID: $($app_id)"
Add-Content -Path .\oidc.yaml -Value '      clientSecret:
        name: openid-client-secret-azuread
      extraScopes:
      - email
      - profile
      extraAuthorizeParameters:
        include_granted_scopes: "true"
      claims:
        preferredUsername:
        - email
        - upn
        name:
        - name
        email:
        - email' --WA
Add-Content -Path .\oidc.yaml -Value "issuer: https://login.microsoftonline.com/$($tenant_id)"

oc apply -f oidc.yaml

#Remove-Item .\manifest.json

#Remove-Item .\oidc.yaml

#New-Item oidc.yaml

#Set-Item oidc.yaml ''