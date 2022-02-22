$rg = "sc-aks-rg"
$acr = "scacrforaks"
$cluster = "sc-aks-cluster"

az group create --name $rg --location eastus

az acr create --resource-group $rg --name $acr --sku Basic

az acr login --name $acr

az acr list --resource-group $rg --query "[].{acrLoginServer:loginServer}" --output table

az aks create --resource-group $rg --name $cluster --node-count 2 --generate-ssh-keys --attach-acr $acr

#az aks install-cli

az aks get-credentials --resource-group $rg --name $cluster




##Rough work

#create new namespace in cluster

#az acr repository list --name scacrforaks --output table

#az acr repository show-tags --name scacrforaks --repository azure-vote-front --output table

#az acr show --name scacrforaks --query "id" --output tsv

#az ad sp create-for-rbac --name sc-principal --scopes /subscriptions/549cf74a-fcb0-49d2-8a63-968ea8b2b1f8/resourceGroups/sc-aks-rg/providers/Microsoft.ContainerRegistry/registries/scacrforaks --role acrpull

#az acr credential show -n scacrforaks