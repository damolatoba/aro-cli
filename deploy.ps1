# Declaration of Resource Prefix parameter -ResourcePrefix. This parameter value is added as prefix to the names of your resources.
param(
    [Parameter(Mandatory=$true)]
    [string]
    $Organization,

    [Parameter(Mandatory=$true)]
    [string]
    $Project,

    [Parameter(Mandatory=$true)]
    [string]
    $RepoName,

    [Parameter(Mandatory=$true)]
    [ValidateLength(3,3)]
    [string]
    $ResourcePrefix
)

#Full url to azure devops organization
$OrgUrl = 'https://dev.azure.com/'+$Organization+'/'

#External repository to be cloned
$SrcRepo = 'https://SegSrcOrg@dev.azure.com/SegSrcOrg/SegSrcProj/_git/SegRepo'

#External repository username
$SrcRepoUser = 'Segun.Salami'

#Set external repository password as environment variable
$env:AZURE_DEVOPS_EXT_GIT_SOURCE_PASSWORD_OR_PAT = 'veikt725rd5kb6ngy7vm3saznpjwsforjn5hmdupwqffslekoosa'

#Pipeline name
$NewPipeline = 'Main Build'

# Enter Resource Group Name here.
$ResourceGroupName = $ResourcePrefix.ToUpper()+'-E2-D-RGP-APP-01'

# Enter Location here
$Location = 'EastUs2'
    
# Enter ACR Name here                           
$ACRName = $ResourcePrefix.ToLower()+'e2dacr1'
    
# Enter AKS Name here                
$AKSName =  'KubernetesDemoAKS' 

$SubDetails = $(az account show --query '[id, name ]' -o tsv)
$SubID = $SubDetails[0]
$SubName = $SubDetails[1]

## Create a Resource Group

az group create --location $Location --resource-group $ResourceGroupName

## Create an Azure Container Registry (ACR)

az acr create --name $ACRName --resource-group $ResourceGroupName --location $Location --sku Basic

## Create an Azure Kubernetes Service (AKS)

az aks create --resource-group $ResourceGroupName --name $AKSName --location $Location --attach-acr $ACRName --generate-ssh-keys

## Get and Store AKS credentials locally

az aks get-credentials --resource-group $ResourceGroupName --name $AKSName --overwrite-existing

#Create Service Pricipal with Resource Group scope
$aksServiceConnection = az ad sp create-for-rbac --name ask-connector --role Contributor --scopes /subscriptions/$SubID/resourceGroups/$ResourceGroupName | ConvertFrom-Json
$appId = $($aksServiceConnection.appId)
$displayName = $($aksServiceConnection.displayName)
$SPPassword = $($aksServiceConnection.password)
$tenant = $($aksServiceConnection.tenant)

#Assign container registry owner role to service principal
$ACR_REGISTRY_ID=$(az acr show --name $ACRName --query id --output tsv)
az role assignment create --assignee $appId --scope $ACR_REGISTRY_ID --role owner
$AKS_ID=$(az aks show --name $AKSName --resource-group $ResourceGroupName --query id --output tsv)
az role assignment create --assignee $appId --scope $AKS_ID --role owner

# Install azure devops extension module is not installed.
if($(az extension show --name azure-devops) -eq ""){
    az extension add --name azure-devops
}

#Create project is project does not exist.
if($(az devops project list --organization $OrgUrl --query "value[?contains(name, '$Project')].id | length(@)") -eq 0){
    az devops project create --name $Project --organization $OrgUrl
}

#Create new repository if it doesn't exist and clone from expernal repository
if($(az repos list --organization $OrgUrl --project $Project --query "[?contains(name, '$RepoName')].id | length(@)") -eq 0){
    az repos create --name $RepoName --organization $OrgUrl --project $Project
    az repos import create --git-source-url $SrcRepo --user-name $SrcRepoUser --organization $OrgUrl --project $Project --repository $RepoName --requires-authorization
}

#Create pipeline
az pipelines create --name $NewPipeline --repository $RepoName --organization $OrgUrl --project $Project --branch master --repository-type tfsgit --yml-path 'src/azure-pipelines.yml'



#Create variable group'
az pipelines variable-group create --name aks-project-variables --organization $OrgUrl --project $Project --authorize --variables appID=$appId SPName=$SPName SPPassword=$SPPassword tenant=$tenant subscriptionName=$SubID subscriptionID=$SubID registryName=$ACRName
