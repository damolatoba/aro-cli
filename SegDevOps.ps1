# Declaration of parameters for organization and project
param(
    [Parameter(Mandatory=$true)]
    [string]
    $Organization,

    [Parameter(Mandatory=$true)]
    [string]
    $Project,

    [Parameter(Mandatory=$true)]
    [string]
    $RepoName
)

#Full url to azure devops organization
$OrgUrl = 'https://dev.azure.com/'+$Organization
#External repository to be cloned
$SrcRepo = 'https://appliedis@dev.azure.com/appliedis/AIS%20Docs/_git/Code%20Samples'
#External repository username
$SrcRepoUser = 'Segun.Salami'
#Set external repository password as environment variable
$env:AZURE_DEVOPS_EXT_GIT_SOURCE_PASSWORD_OR_PAT = 'rg4mokwt4qb4fmkgwujdaihhoua5b6fxbxktzsdv67ofcu3hazbq'
#Pipeline name
$NewPipeline = 'Main Build'

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
    az repos import create --git-source-url $AISrepo --user-name $RepoUsername --organization $OrgUrl --project $Project --repository $RepoName --requires-authorization
}

#Create pipeline
az pipelines create --name $PipelineName --repository $RepoName --organization $OrgUrl --project $Project --branch master --repository-type tfsgit
#az pipelines create --name $PipelineName --repository $RepoName --branch master --repository-type tfsgit --yml-path 'src/azure-pipelines.yml'

#Create Service Principal