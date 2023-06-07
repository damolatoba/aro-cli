# Declaration of Resource Prefix parameter -ResourcePrefix. This parameter value is added as prefix to the names of your resources.
param(
    [Parameter(Mandatory=$true)]
    [ValidateLength(3,3)]
    [string]
    $ResourcePrefix
)

# Enter Resource Group Name here.
$ResourceGroupName = $ResourcePrefix.ToUpper()+'-E2-D-RGP-APP-01'

# Enter Location here
$Location = 'EastUs2'
    
# Enter ACR Name here                           
$ACRName = $ResourcePrefix.ToLower()+'e2dacr1'
    
# Enter AKS Name here                
$AKSName =  'KubernetesDemoAKS' 


## Create a Resource Group

az group create --location $Location --resource-group $ResourceGroupName

## Create an Azure Container Registry (ACR)

az acr create --name $ACRName --resource-group $ResourceGroupName --location $Location --sku Basic

## Create an Azure Kubernetes Service (AKS)

az aks create --resource-group $ResourceGroupName --name $AKSName --location $Location --attach-acr $ACRName --generate-ssh-keys

## Get and Store AKS credentials locally

az aks get-credentials --resource-group $ResourceGroupName --name $AKSName --overwrite-existing


